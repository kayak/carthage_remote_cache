require "fileutils"

class CarthageArchive
  attr_reader :archive_filename, :archive_path

  def initialize(framework_name, platform)
    raise AppError.new, "Platform #{platform.inspect} needs to be a symbol" unless platform.kind_of?(Symbol)

    @framework_name = framework_name
    @platform = platform
    @archive_filename = "#{framework_name}-#{platform}.zip"
    @archive_path = @archive_filename
  end

  def unpack_archive(shell, carthage_build_dir = CARTHAGE_BUILD_DIR)
    raise AppError.new, "Archive #{@archive_path} is missing" unless File.exist?(@archive_path)

    delete_existing_build_framework_if_exists(carthage_build_dir)

    $LOG.debug("Unpacking #{@archive_path}, file size: #{formatted_archive_size}")
    shell.unpack(@archive_path)
  end

  def delete_archive
    File.delete(@archive_path) if File.exist?(@archive_path)
  end

  def archive_size
    raise AppError.new, "Archive #{@archive_path} is missing" unless File.exist?(@archive_path)
    File.size(@archive_path)
  end

  private

  def formatted_archive_size
    format_file_size(archive_size)
  end

  def delete_existing_build_framework_if_exists(carthage_build_dir)
    framework_path = File.join(carthage_build_dir, "#{@framework_name}.xcframework")
    if File.exist?(framework_path)
      $LOG.debug("Deleting #{framework_path}")
      FileUtils.rm_rf(framework_path)
    end
  end
end
