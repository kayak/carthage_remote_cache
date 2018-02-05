require 'uri'

class Configuration

    class UserConfig
        attr_accessor :server
    end

    @@user_config = UserConfig.new

    def self.setup
        yield(@@user_config)
    end

    attr_reader :xcodebuild_version, :swift_version, :carthage_dependencies, :server_uri

    def initialize
        initialize_env
        initialize_cartrcfile
    end

    def all_framework_names
        version_files.flat_map { |vf| vf.framework_names }.uniq.sort
    end

    def to_s
        <<~EOS
            Xcodebuild: #{@xcodebuild_version}
            ---
            Swift: #{@swift_version}
            ---
            Server: #{@server_uri.to_s}
            ---
            Cartfile.resolved:
            #{@carthage_dependencies.join("\n")}
            ---
            Local Build Frameworks:
            #{framework_names_with_platforms.join("\n")}
        EOS
    end

    private

    def initialize_env
        xcodebuild_raw_version = sh("xcodebuild -version")
        @xcodebuild_version = xcodebuild_raw_version[/Build version (.*)$/, 1]
        raise "Could not parse build version from '#{xcodebuild_raw_version}'" if @xcodebuild_version.nil?

        swift_raw_version = sh("swift -version")
        @swift_version = swift_raw_version[/Apple Swift version (.*) \(/, 1]
        raise "Could not parse swift version from '#{raw_swift_version}'" if @swift_version.nil?

        raise "Misssing #{CARTFILE_RESOLVED}" unless File.exist?(CARTFILE_RESOLVED)
        @carthage_dependencies = File.readlines(CARTFILE_RESOLVED)
            .map { |line| CarthageDependency.parse_cartfile_resolved_line(line) }
            .compact
    end

    def initialize_cartrcfile
        raise "Configuration file #{CARTRCFILE} was not found, consider creating one by running `carthagerc init`" unless File.exist?(CARTRCFILE)

        # Populate class variable @@user_config.
        load File.join(Dir.pwd, CARTRCFILE)

        raise "Missing 'server' configuration in #{CARTRCFILE}" if @@user_config.server.nil? || @@user_config.server.empty?
        @server_uri = URI.parse(@@user_config.server)
    end

    def framework_names_with_platforms
        version_files.flat_map do |vf|
            vf.platforms_by_framework.flat_map do |framework_name, platforms|
                "#{framework_name} #{vf.version} #{platforms}"
            end
        end
    end

    def version_files
        @carthage_dependencies.map { |d| VersionFile.new(d.version_filepath) }
    end

end
