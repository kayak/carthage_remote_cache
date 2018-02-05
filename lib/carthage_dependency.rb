class CarthageDependency

    class << self
        # Parses Cartfile.resolved dependency entry, e.g.
        #   github "CocoaLumberjack/CocoaLumberjack" "3.2.1"
        def parse_cartfile_resolved_line(line)
            line.strip!
            matches = line.match(/^(\w+)\s+\"([^\"]+)\"(\s+\"([^\"]+)\")$/)
            return nil if matches.nil?
            if matches.length == 5
                CarthageDependency.new(type: matches[1], repository: matches[2], version: matches[4])
            else
                nil
            end
        end
    end

    attr_reader :type, :repository, :version

    def initialize(args)
        @type = args[:type]
        @repository = args[:repository]
        @version = args[:version]
    end

    # Since one Cartfile.resolved entry may produce multiple differently named frameworks,
    # this is an entry point to identifying a framework name.
    def guessed_framework_basename
        case @type
        when "github"
            repository.split("/").last
        else
            raise "Determining version_filename from #{@type} dependency is not yet supported"
        end
    end

    def version_filename
        ".#{guessed_framework_basename}.version"
    end

    def version_filepath
        File.join(CARTHAGE_BUILD_DIR, version_filename)
    end

    def validate_version_file(version_file)
        raise OutdatedFrameworkBuildError.new, version_validation_message(version_file) if @version != version_file.version
    end

    def to_s
        "#{@type} \"#{@repository}\" \"#{@version}\""
    end

    private

    def version_validation_message(version_file)
        <<~EOS
            Outdated version of '#{guessed_framework_basename}' framework detected:
                Expected version '#{@version}'
                Found version '#{version_file.version}'

            Please run `carthage bootstrap` to build frameworks.
        EOS
    end

end
