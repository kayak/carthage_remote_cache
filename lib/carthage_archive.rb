class CarthageArchive

    attr_reader :archive_filename, :archive_path

    def initialize(framework_name, platform)
        raise "Platform #{platform.inspect} needs to be a symbol" unless platform.kind_of?(Symbol)

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
    def create_archive(options)
        puts "Archiving #{@framework_name} in #{@platform}" if options[:verbose]

        platform_path = File.join(CARTHAGE_BUILD_DIR, platform_to_carthage_dir_string(@platform))
        framework_path = File.join(platform_path, "#{@framework_name}.framework")

        raise "Archive can't be created, no built framework at #{framework_path}" unless Dir.exist?(framework_path)

        dsym_path = File.join(platform_path, "#{@framework_name}.framework.dSYM")
        binary_path = File.join(framework_path, @framework_name)
        bcsymbolmap_paths = find_bcsymbolmap_paths(platform_path, binary_path)

        raise "Directory #{framework_path} is missing. If framework name doesn't match repository, please add mapping via Cartrcfile" unless Dir.exist?(framework_path)
        raise "File #{dsym_path} is missing" unless File.exist?(dsym_path)
        raise "File #{binary_path} is missing, failed to read .bcsymbolmap files" unless File.exist?(binary_path)

        puts framework_path if options[:verbose]
        puts dsym_path if options[:verbose]
        puts bcsymbolmap_paths if options[:verbose]

        delete_archive
        sh("zip -r #{quote @archive_path} #{quote framework_path} #{quote dsym_path} #{quote bcsymbolmap_paths}")
        puts "#{@archive_path} #{File.size @archive_path}" if options[:verbose]
    end

    def unpack_archive(options)
        raise "Archive #{@archive_path} is missing" unless File.exist?(@archive_path)
        puts "Unpacking #{@archive_path} #{File.size @archive_path}" if options[:verbose]
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

end
