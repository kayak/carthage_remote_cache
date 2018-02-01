require 'test/unit'
require 'carthage_remote_cache'

class VersionFileTests < Test::Unit::TestCase

    def setup
        fixtures_dir = File.expand_path("../fixtures", __FILE__)
        @lumberjack_path = File.join(fixtures_dir, 'CocoaLumberjack.version')
        @lottie_path = File.join(fixtures_dir, 'lottie.version')
    end

    def test_parse_lumberjack
        version_file = VersionFile.new(@lumberjack_path)
        assert_equal(version_file.frameworks_by_platform, {
            :iOS => ['CocoaLumberjackSwift', 'CocoaLumberjack'],
            :macOS => ['CocoaLumberjackSwift', 'CocoaLumberjack'],
            :tvOS => ['CocoaLumberjackSwift', 'CocoaLumberjack'],
            :watchOS => ['CocoaLumberjackSwift', 'CocoaLumberjack'],
        })
    end

    def test_parse_lottie
        version_file = VersionFile.new(@lottie_path)
        assert_equal(version_file.frameworks_by_platform, {
            :iOS => ['Lottie'],
            :macOS => [],
            :tvOS => [],
            :watchOS => [],
        })
    end

end
