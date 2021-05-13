require "concurrent"

class UploadCommand
  def self.new_with_defaults(options)
    shell = ShellWrapper.new
    config = Configuration.new(shell)
    networking = Networking.new(config)
    api = API.new(shell, config, networking, options)

    UploadCommand.new(
      config: config,
      networking: networking,
      api: api,
    )
  end

  def initialize(args)
    @config = args[:config]
    @networking = args[:networking]
    @api = args[:api]
  end

  def run
    @config.ensure_shell_commands
    @api.verify_server_version
    @api.verify_build_dir_matches_cartfile_resolved

    pool = Concurrent::FixedThreadPool.new(THREAD_POOL_SIZE)

    $LOG.debug("Will upload frameworks: #{@config.all_framework_names}")

    @mutex = Mutex.new
    @number_of_uploaded_archives = 0
    @number_of_skipped_archives = 0
    @total_archive_size = 0
    errors = Concurrent::Array.new

    for carthage_dependency in @config.carthage_resolved_dependencies
      pool.post(carthage_dependency) do |carthage_dependency|
        begin
          upload(carthage_dependency)
        rescue => e
          errors << e
        end
      end
    end

    pool.shutdown
    pool.wait_for_termination

    if errors.count > 0
      raise MultipleErrorsError.new(errors)
    else
      puts "Uploaded #{@number_of_uploaded_archives} archives " +
             "(#{format_file_size(@total_archive_size)}), " +
             "skipped #{@number_of_skipped_archives}."
    end
  end

  private

  def upload(carthage_dependency)
    version_file = carthage_dependency.new_version_file

    if @api.version_file_matches_server?(carthage_dependency, version_file)
      $LOG.debug("Version file #{version_file.path} matches server version, skipping upload")
      @mutex.synchronize do
        @number_of_skipped_archives += version_file.number_of_frameworks
      end
      return
    end

    @networking.upload_version_file(carthage_dependency)

    version_file.frameworks_by_platform.each do |platform, framework_names|
      for framework_name in framework_names
        archive_size = @api.create_and_upload_archive(carthage_dependency, framework_name, platform)
        @mutex.synchronize do
          @number_of_uploaded_archives += 1
          @total_archive_size += archive_size
        end
      end
    end
  end
end
