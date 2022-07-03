class API
  def initialize(shell, config, networking, options)
    @shell = shell
    @config = config
    @networking = networking
    @options = options
    @unpack_mutex = Mutex.new
  end

  def verify_server_version
    server_version = @networking.get_server_version
    unless server_version == VERSION
      raise ServerVersionMismatchError.new, version_mismatch_message(server_version)
    end
  end

  def verify_build_dir_matches_cartfile_resolved
    errors = []
    for carthage_dependency in @config.carthage_resolved_dependencies
      begin
        version_file = carthage_dependency.new_version_file
        carthage_dependency.verify_version_in_version_file(version_file)
      rescue VersionFileDoesNotExistError => e
        errors << OutdatedFrameworkBuildError.new(
          carthage_dependency.guessed_framework_basename,
          "-",
          carthage_dependency.version
        )
      rescue OutdatedFrameworkBuildError => e
        errors << e
      end
    end
    if errors.count > 0
      raise FrameworkValidationError.new(errors)
    end
  end

  def version_file_matches_server?(carthage_dependency, version_file, platforms)
    if @options[:force]
      false
    else
      server_version_file = @networking.download_version_file(carthage_dependency, platforms)
      result = version_file.same_content?(server_version_file)
      server_version_file.remove unless server_version_file.nil?
      result
    end
  end

  # @return zip archive size in Bytes
  def create_and_upload_archive(carthage_dependency, framework, platform)
    archive = framework.make_archive(platform)
    archive.compress_archive(@shell)
    archive_size = archive.archive_size
    begin
      checksum = crc32(archive.archive_path)
      @networking.upload_framework_archive(archive.archive_path, carthage_dependency, framework.name, platform, checksum)
    ensure
      archive.delete_archive
    end
    archive_size
  end

  # @return zip archive size in Bytes
  # @raise AppError if download or checksum validation fails
  def download_and_unpack_archive(carthage_dependency, framework, platform)
    result = @networking.download_framework_archive(carthage_dependency, framework, platform)
    if result.nil?
      raise AppError.new, "Failed to download framework #{carthage_dependency} – #{framework.name} (#{platform}). Please `upload` the framework first."
    end

    archive = result[:archive]
    remote_checksum = result[:checksum]
    local_checksum = crc32(archive.archive_path)

    if local_checksum != remote_checksum
      raise AppError.new, checksum_error_message(archive.archive_path, remote_checksum, local_checksum)
    end

    archive_size = archive.archive_size
    begin
      $LOG.debug("Downloaded #{archive.archive_path}")
      # Can't unpack multiple archives concurrently.
      @unpack_mutex.synchronize do
        archive.unpack_archive(@shell)
      end
    ensure
      archive.delete_archive
    end
    archive_size
  end

  private

  def version_mismatch_message(server_version)
    <<~EOS
      Version mismatch:
        Cache server version: #{server_version}
        Client version:       #{VERSION}

      Please use the same version as cache server by running:
      $ gem install carthage_remote_cache -v #{server_version}
    EOS
  end

  def checksum_error_message(path, remote, local)
    <<~EOS
      Checksums for '#{path}' do not match:
        Remote: #{remote}
        Local:  #{local}
    EOS
  end
end
