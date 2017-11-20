require_relative 'utils'

class CarthageArchive

    attr_reader :archive_filename, :archive_path

    def initialize(framework_name, platform)
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
        platform_path = "Carthage/Build/#{@platform}"

        puts '---' if options[:verbose]
        puts "Archiving #{@framework_name} in #{@platform}" if options[:verbose]

        framework_path = "#{platform_path}/#{@framework_name}.framework"
        dsym_path = "#{platform_path}/#{@framework_name}.framework.dSYM"
        binary_path = "#{framework_path}/#{@framework_name}"
        bcsymbolmap_paths = find_bcsymbolmap_paths(platform_path, binary_path)

        raise "Directory #{framework_path} doesn't exist" unless Dir.exist? framework_path
        raise "File #{dsym_path} doesn't exist" unless File.exist? dsym_path
        raise "File #{binary_path} doesn't exit" unless File.exist? binary_path

        puts framework_path if options[:verbose]
        puts dsym_path if options[:verbose]
        puts bcsymbolmap_paths if options[:verbose]

        delete_archive
        sh("zip -r #{quote @archive_path} #{quote framework_path} #{quote dsym_path} #{quote bcsymbolmap_paths}")
        puts "#{@archive_path} #{File.size @archive_path}" if options[:verbose]
    end

    def delete_archive
        File.delete(@archive_path) if File.exists?(@archive_path)
    end

    private def find_bcsymbolmap_paths(platform_path, binary_path)
        raw_dwarfdump = dwarfdump(binary_path)
        uuids = parse_uuids(raw_dwarfdump)
        bcsymbolmap_paths = uuids.map { |uuid| "#{platform_path}/#{uuid}.bcsymbolmap" }.select { |path| File.exist?(path) }
        bcsymbolmap_paths
    end

    private def dwarfdump(binary_path)
        sh("/usr/bin/xcrun dwarfdump --uuid \"#{binary_path}\"")
    end

    # Example dwarfdump link:
    # UUID: 618BEB79-4C7F-3692-B140-131FB983AC5E (i386) Carthage/Build/iOS/CocoaLumberjackSwift.framework/CocoaLumberjackSwift
    private def parse_uuids(raw_dwarfdump)
        raw_dwarfdump.split("\n").map { |line| line[/^UUID: ([A-Z0-9\-]+)\s+\(.*$/, 1] }.compact
    end

end
