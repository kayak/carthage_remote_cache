require 'json'

# .version file representation, see Carthage documentation on them:
# https://github.com/Carthage/Carthage/blob/master/Documentation/VersionFile.md
class VersionFile

    attr_reader :frameworks_by_platform

    def initialize(path)
        @path = path
        @frameworks_by_platform = parse_frameworks_by_platform(path)
    end

    def parse_platform_array(array)
        if array.kind_of?(Array)
            array.map { |entry| entry['name'] }
        else
            []
        end
    end

    def parse_frameworks_by_platform(path)
        raise "Invalid path #{path} for version file" unless File.exist?(path)

        file = File.read(path)
        json = JSON.parse(file)

        {
            :iOS => parse_platform_array(json['iOS']),
            :macOS => parse_platform_array(json['Mac']),
            :tvOS => parse_platform_array(json['tvOS']),
            :watchOS => parse_platform_array(json['watchOS']),
        }
    end

end
