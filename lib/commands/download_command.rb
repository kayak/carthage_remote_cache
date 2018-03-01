require 'concurrent'

class DownloadCommand
  def self.new_with_defaults(options)
    shell = ShellWrapper.new
    config = Configuration.new(shell)
    networking = Networking.new(config)
    api = API.new(shell, config, networking, options)

    DownloadCommand.new(
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

    pool = Concurrent::FixedThreadPool.new(THREAD_POOL_SIZE)

    @mutex = Mutex.new
    @number_of_downloaded_archives = 0
    @number_of_skipped_archives = 0
    @total_archive_size = 0
    errors = Concurrent::Array.new

    for carthage_dependency in @config.carthage_resolved_dependencies
      pool.post(carthage_dependency) do |carthage_dependency|
        begin
          download(carthage_dependency)
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
      puts "Downloaded and extracted #{@number_of_downloaded_archives} archives " +
             "(#{format_file_size(@total_archive_size)}), " +
             "skipped #{@number_of_skipped_archives} archives."
    end
  end

  private

  def download(carthage_dependency)
    local_version_file =
      if File.exist?(carthage_dependency.version_filepath)
        carthage_dependency.new_version_file
      else
        nil
      end

    if !local_version_file.nil? && @api.version_file_matches_server?(carthage_dependency, local_version_file)
      $LOG.debug("Version file #{local_version_file.path} matches server version, skipping download")
      @mutex.synchronize do
        @number_of_skipped_archives += local_version_file.number_of_frameworks
      end
      return
    end

    version_file = @networking.download_version_file(carthage_dependency)
    raise AppError.new, "Version file #{carthage_dependency.version_filename} is not present on the server, please run `carthagerc upload` first" if version_file.nil?

    version_file.frameworks_by_platform.each do |platform, framework_names|
      for framework_name in framework_names
        archive_size = @api.download_and_unpack_archive(carthage_dependency, framework_name, platform)
        @mutex.synchronize do
          @number_of_downloaded_archives += 1
          @total_archive_size += archive_size
        end
      end
    end
    version_file.move_to_build_dir
  end
end
