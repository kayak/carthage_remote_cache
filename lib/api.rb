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
      @networking.upload_framework_archive(archive.archive_path, carthage_dependency, framework_name, platform)
    ensure
      archive.delete_archive
    end
    archive_size
  end

  # @return zip archive size in Bytes or nil if archive download failed
  def download_and_unpack_archive(carthage_dependency, framework_name, platform)
    archive = @networking.download_framework_archive(carthage_dependency, framework_name, platform)
    return nil if archive.nil?
    archive_size = archive.archive_size
    begin
      $LOG.debug("Downloaded #{archive.archive_path}")
      archive.unpack_archive(@shell)
    ensure
      archive.delete_archive
    end
    archive_size
  end
end
