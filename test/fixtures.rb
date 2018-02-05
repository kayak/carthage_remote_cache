FIXTURES_DIR = File.expand_path("../fixtures", __FILE__)

class Fixtures

    class << self

        def lumberjack_version_file
            VersionFile.new(lumberjack_path)
        end

        def lumberjack_path
            File.join(FIXTURES_DIR, 'lumberjack.version')
        end

        def baddie_version_file
            VersionFile.new(baddie_path)
        end

        def baddie_path
            File.join(FIXTURES_DIR, 'baddie.version')
        end

    end

end
