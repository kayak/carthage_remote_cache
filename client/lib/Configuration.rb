require 'yaml'
require_relative 'CarthageDependency'
require_relative 'utils'

class Configuration

    attr_reader :server, :platforms

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
        @dependencies = File.readlines("Cartfile.resolved")
            .map { |line| CarthageDependency.parse(line) }
            .compact

    end

    def initialize_cartrcfile(options)
        raise "Misssing Cartrcfile" unless File.exists?('Cartrcfile')
        main = YAML.load_file('Cartrcfile')
        puts "Cartrcfile: #{main.inspect}" if options[:verbose]

        @server = main['server']
        raise "Missing 'server' configuration in Cartrcfile" if @server.nil?

        @platforms = main['platforms'] || ['iOS', 'macOS', 'tvOS', 'watchOS']

        @repository_to_framework_names = {}
        main['dependencies'].each do |item|
            dependency = CarthageDependency.parse(item['dependency']['name'])
            @repository_to_framework_names[dependency.repository] = item['dependency']['frameworks']
        end
        puts "Repository to framework names: #{@repository_to_framework_names.inspect}" if options[:verbose]
    end

    def mapped_framework_names(repository)
        @repository_to_framework_names[repository]
    end

    def framework_names
        @dependencies
            .map { |d| d.framework_names(self) }
            .flatten
    end

    def to_s
        <<~EOS
            Xcodebuild: #{@xcodebuild_version}
            ---
            Swift: #{@swift_version}
            ---
            Cartfile.resolved:
            #{@dependencies.join("\n")}
            ---
            Platforms: #{@platforms}
        EOS
    end
end
