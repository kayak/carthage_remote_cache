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

    # TODO What is this?
    def produced_framework_names(config)
        names = config.produced_framework_names(self)
        if names.nil?
            case @type
            when "github"
                name = @repository.split("/").last
                [name]
            else
                raise "Framework name resolution not supported, please provide mapping in Cartrcfile"
            end
        else
            names
        end
    end

    # TODO where is this used
    def to_s
        "#{@type} \"#{@repository}\" \"#{@version}\""
    end

end
