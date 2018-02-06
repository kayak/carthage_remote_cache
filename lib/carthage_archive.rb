class CarthageArchive
  attr_reader :archive_filename, :archive_path

  def initialize(framework_name, platform)
    raise AppError.new, "Platform #{platform.inspect} needs to be a symbol" unless platform.kind_of?(Symbol)

    @framework_name = framework_name
    @platform = platform
    @archive_filename = "#{framework_name}-#{platform}.zip"
    @archive_path = @archive_filename
  end

  # Aggregate following files:
  # - Carthage/Build/iOS/Alamofire.framework
  # - Carthage/Build/iOS/Alamofire.framework/Alamofire
  # - Carthage/Build/iOS/618BEB79-4C7F-3692-B140-131FB983AC5E.bcsymbolmap
  # into Alamofire-iOS.zip
  def create_archive
    $LOG.debug("Archiving #{@framework_name} for #{@platform}")

    platform_path = File.join(CARTHAGE_BUILD_DIR, platform_to_carthage_dir_string(@platform))
    framework_path = File.join(platform_path, "#{@framework_name}.framework")
    raise AppError.new, "Archive can't be created, no framework directory at #{framework_path}" unless Dir.exist?(framework_path)

    dsym_path = File.join(platform_path, "#{@framework_name}.framework.dSYM")
    raise AppError.new, "DSYM File #{dsym_path} is missing" unless File.exist?(dsym_path)

    binary_path = File.join(framework_path, @framework_name)
    raise AppError.new, "Binary #{binary_path} is missing, failed to read .bcsymbolmap files" unless File.exist?(binary_path)

    bcsymbolmap_paths = find_bcsymbolmap_paths(platform_path, binary_path)

    archived_paths = [framework_path, dsym_path] + bcsymbolmap_paths

    $LOG.debug("Adding > #{archived_paths.inspect}")

    delete_archive
    sh("zip -r #{quote @archive_path} #{quote archived_paths}")
    $LOG.debug("Created #{@archive_path} archive, file size: #{formatted_archive_size}")
  end

  def unpack_archive
    raise AppError.new, "Archive #{@archive_path} is missing" unless File.exist?(@archive_path)
    $LOG.debug("Unpacking #{@archive_path}, file size: #{formatted_archive_size}")
    sh("unzip -o #{quote @archive_path}")
  end

  def delete_archive
    File.delete(@archive_path) if File.exist?(@archive_path)
  end

  private

  def find_bcsymbolmap_paths(platform_path, binary_path)
    raw_dwarfdump = dwarfdump(binary_path)
    uuids = parse_uuids(raw_dwarfdump)
    bcsymbolmap_paths = uuids.map { |uuid| File.join(platform_path, "#{uuid}.bcsymbolmap") }.select { |path| File.exist?(path) }
    bcsymbolmap_paths
  end

  def dwarfdump(binary_path)
    sh("/usr/bin/xcrun dwarfdump --uuid \"#{binary_path}\"")
  end

  # Example dwarfdump link:
  # UUID: 618BEB79-4C7F-3692-B140-131FB983AC5E (i386) Carthage/Build/iOS/CocoaLumberjackSwift.framework/CocoaLumberjackSwift
  def parse_uuids(raw_dwarfdump)
    lines = raw_dwarfdump.split("\n")
    uuids = lines.map { |line| line[/^UUID: ([A-Z0-9\-]+)\s+\(.*$/, 1] }
    uuids.compact
  end

  # E.g. "1.4MB"
  def formatted_archive_size
    size = File.size(@archive_path)
    megabytes = size / 1024.0 / 1024.0
    "#{megabytes.round(1)}MB"
  end
end
