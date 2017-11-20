class CarthageDependency
    class << self
        def parse(cartfile_resolved_line)
            cartfile_resolved_line.strip!
            matches = cartfile_resolved_line.match(/^(\w+)\s+\"([^\"]+)\"(\s+\"([^\"]+)\")?$/)
            return nil if matches.nil?
            case matches.length
            when 5
                CarthageDependency.new(type: matches[1], repository: matches[2], version: matches[4])
            when 3
                CarthageDependency.new(type: matches[1], repository: matches[2], version: nil)
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

    def framework_names(config)
        names = config.mapped_framework_names(@repository)
        if names.nil?
            puts @type
            puts @repository
            @repository.split("/").last
        else
            names
        end
    end

    def to_s
        "#{@type} \"#{@repository}\" \"#{@version}\""
    end
end
