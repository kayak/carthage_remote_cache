require "fileutils"

class FrameworkCarthageArchive < CarthageArchive

  # Aggregate following files:
  # - Carthage/Build/iOS/Alamofire.framework
  # - Carthage/Build/iOS/Alamofire.framework/Alamofire
  # - Carthage/Build/iOS/618BEB79-4C7F-3692-B140-131FB983AC5E.bcsymbolmap
  # into Alamofire-iOS.zip
  def compress_archive(shell, carthage_build_dir = CARTHAGE_BUILD_DIR)
    $LOG.debug("Archiving #{@framework_name} for #{@platform}")

    platform_path = File.join(carthage_build_dir, platform_to_carthage_dir_string(@platform))
    framework_path = File.join(platform_path, "#{@framework_name}.framework")
    raise MissingFrameworkDirectoryError.new, "Archive can't be created, no framework directory at #{framework_path}" unless Dir.exist?(framework_path)

    # It's very likely, that binary releases don't contain DSYMs.
    dsym_path = File.join(platform_path, "#{@framework_name}.framework.dSYM")
    unless File.exist?(dsym_path)
      $LOG.error("DSYM File #{dsym_path} not found, continuing")
      dsym_path = nil
    end

    binary_path = File.join(framework_path, @framework_name)
    raise AppError.new, "Binary #{binary_path} is missing, failed to read .bcsymbolmap files" unless File.exist?(binary_path)

    bcsymbolmap_paths = find_bcsymbolmap_paths(shell, platform_path, binary_path)

    input_paths = []
    input_paths << framework_path
    input_paths << dsym_path unless dsym_path.nil?
    input_paths += bcsymbolmap_paths

    $LOG.debug("Adding > #{input_paths.inspect}")

    delete_archive
    shell.archive(input_paths, @archive_path)
    $LOG.debug("Created #{@archive_path} archive, file size: #{formatted_archive_size}")
  end

  private

  def find_bcsymbolmap_paths(shell, platform_path, binary_path)
    raw_dwarfdump = shell.dwarfdump(binary_path)
    uuids = parse_uuids(raw_dwarfdump)
    bcsymbolmap_paths = uuids.map { |uuid| File.join(platform_path, "#{uuid}.bcsymbolmap") }.select { |path| File.exist?(path) }
    bcsymbolmap_paths
  end

  # Example dwarfdump link:
  # UUID: 618BEB79-4C7F-3692-B140-131FB983AC5E (i386) Carthage/Build/iOS/CocoaLumberjackSwift.framework/CocoaLumberjackSwift
  def parse_uuids(raw_dwarfdump)
    lines = raw_dwarfdump.split("\n")
    uuids = lines.map { |line| line[/^UUID: ([A-Z0-9\-]+)\s+\(.*$/, 1] }
    uuids.compact
  end
end
