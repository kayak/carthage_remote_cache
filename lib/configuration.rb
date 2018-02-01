require 'yaml'

class Configuration

    attr_reader :xcodebuild_version, :swift_version, :carthage_dependencies, :server, :platforms

    def initialize(options)
        initialize_env
        initialize_cartrcfile(options)
    end

    def initialize_env
        xcodebuild_raw_version = sh("xcodebuild -version")
        @xcodebuild_version = xcodebuild_raw_version[/Build version (.*)$/, 1]
        raise "Could not parse build version from '#{xcodebuild_raw_version}'" if @xcodebuild_version.nil?

        swift_raw_version = sh("swift -version")
        @swift_version = swift_raw_version[/Apple Swift version (.*) \(/, 1]
        raise "Could not parse swift version from '#{raw_swift_version}'" if @swift_version.nil?

        raise "Misssing Cartfile.resolved" unless File.exists?('Cartfile.resolved')
        @carthage_dependencies = File.readlines("Cartfile.resolved")
            .map { |line| CarthageDependency.parse_cartfile_resolved_line(line) }
            .compact
    end

    def initialize_cartrcfile(options)
        raise "Misssing Cartrcfile" unless File.exists?('Cartrcfile')
        cartrcfile = YAML.load_file('Cartrcfile')
        puts "Cartrcfile: #{cartrcfile.inspect}" if options[:verbose]

        @server = cartrcfile['server']
        raise "Missing 'server' configuration in Cartrcfile" if @server.nil?

        # TODO how to find out which  platforms the framework is available in
        @platforms = cartrcfile['platforms'] || ['iOS', 'macOS', 'tvOS', 'watchOS']

        @repository_to_framework_names = {}
        cartrcfile['dependencies'].each do |item|
            type_and_repository = item['name']
            @repository_to_framework_names[type_and_repository] = item['frameworks']
        end
        puts "Repository to framework names: #{@repository_to_framework_names.inspect}" if options[:verbose]
    end

    # A single cartfile dependency can produce several frameworks.
    def produced_framework_names(dependency)
        key = "#{dependency.type} \"#{dependency.repository}\""
        @repository_to_framework_names[key]
    end

    def all_framework_names
        @carthage_dependencies
            .map { |d| d.produced_framework_names(self) }
            .flatten
    end

    def to_s
        <<~EOS
            Xcodebuild: #{@xcodebuild_version}
            ---
            Swift: #{@swift_version}
            ---
            Cartfile.resolved:
            #{@carthage_dependencies.join("\n")}
            ---
            Platforms: #{@platforms}
        EOS
    end
end
