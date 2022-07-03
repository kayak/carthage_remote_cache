require "fileutils"

class XCFrameworkCarthageArchive < CarthageArchive

  # Compresses `Carthage/Build/GoogleSignIn.xcframework``
  # into `GoogleSignIn-iOS.zip`.`
  def compress_archive(shell, carthage_build_dir = CARTHAGE_BUILD_DIR)
    $LOG.debug("Archiving #{@framework_name} for #{@platform}")

    framework_path = File.join(carthage_build_dir, "#{@framework_name}.xcframework")
    raise MissingFrameworkDirectoryError.new, "Archive can't be created, no xcframework directory at #{framework_path}" unless Dir.exist?(framework_path)

    delete_archive
    shell.archive([framework_path], @archive_path)
    $LOG.debug("Created #{@archive_path} archive, file size: #{formatted_archive_size}")
  end
end
