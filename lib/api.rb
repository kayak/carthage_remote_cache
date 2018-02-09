class API
  def initialize(shell, networking, options)
    @shell = shell
    @networking = networking
    @options = options
  end

  def version_file_matches_server?(carthage_dependency, version_file)
    if @options[:force]
      false
    else
      server_version_file = @networking.download_version_file(carthage_dependency)
      result = version_file.same_content?(server_version_file)
      server_version_file.remove unless server_version_file.nil?
      result
    end
  end

  # @return zip archive size in Bytes
  def create_and_upload_archive(carthage_dependency, framework_name, platform)
    archive = CarthageArchive.new(framework_name, platform)
    archive.create_archive(@shell, carthage_dependency.should_include_dsym)
    archive_size = archive.archive_size
    begin
      checksum = crc32(archive.archive_path)
      @networking.upload_framework_archive(archive.archive_path, carthage_dependency, framework_name, platform, checksum)
    ensure
      archive.delete_archive
    end
    archive_size
  end

  # @return zip archive size in Bytes
  # @raise AppError if download or checksum validation fails
  def download_and_unpack_archive(carthage_dependency, framework_name, platform)
    result = @networking.download_framework_archive(carthage_dependency, framework_name, platform)
    if result.nil?
      raise AppError.new, "Failed to download framework #{carthage_dependency} – #{framework_name} (#{platform}). Please `upload` the framework first."
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
      archive.unpack_archive(@shell)
    ensure
      archive.delete_archive
    end
    archive_size
  end

  private

  def checksum_error_message(path, remote, local)
    <<~EOS
      Checksums for '#{path}' do not match:
        Remote: #{remote}
        Local:  #{local}
    EOS
  end
end
