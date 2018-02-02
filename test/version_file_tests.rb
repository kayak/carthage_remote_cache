require 'test/unit'
require 'carthage_remote_cache'

class VersionFileTests < Test::Unit::TestCase

    def setup
        fixtures_dir = File.expand_path("../fixtures", __FILE__)
        @lumberjack_path = File.join(fixtures_dir, 'CocoaLumberjack.version')
        @lottie_path = File.join(fixtures_dir, 'lottie.version')
    end

    # version

    def test_version_lumberjack
        version_file = VersionFile.new(@lumberjack_path)
        assert_equal('3.2.1', version_file.version)
    end

    def test_version_lottie
        version_file = VersionFile.new(@lottie_path)
        assert_equal('1.5.1', version_file.version)
    end

    # frameworks_by_platform

    def test_frameworks_by_platform_lumberjack
        version_file = VersionFile.new(@lumberjack_path)
        assert_equal(version_file.frameworks_by_platform, {
            :iOS => ['CocoaLumberjackSwift', 'CocoaLumberjack'],
            :macOS => ['CocoaLumberjackSwift', 'CocoaLumberjack'],
            :tvOS => ['CocoaLumberjackSwift', 'CocoaLumberjack'],
            :watchOS => ['CocoaLumberjackSwift', 'CocoaLumberjack'],
        })
    end

    def test_frameworks_by_platform_lottie
        version_file = VersionFile.new(@lottie_path)
        assert_equal(version_file.frameworks_by_platform, {
            :iOS => ['Lottie'],
            :macOS => [],
            :tvOS => [],
            :watchOS => [],
        })
    end

    # platforms_by_framework

    def test_platforms_by_framework_lumberjack
        version_file = VersionFile.new(@lumberjack_path)
        assert_equal(version_file.platforms_by_framework, {
            'CocoaLumberjack' => [:iOS, :macOS, :tvOS, :watchOS],
            'CocoaLumberjackSwift' => [:iOS, :macOS, :tvOS, :watchOS]
        })
    end

    def test_platforms_by_framework_lottie
        version_file = VersionFile.new(@lottie_path)
        assert_equal(version_file.platforms_by_framework, { 'Lottie' => [:iOS] })
    end

    # framework_names

    def test_framework_names_lumberjack
        version_file = VersionFile.new(@lumberjack_path)
        assert_equal(['CocoaLumberjack', 'CocoaLumberjackSwift'], version_file.framework_names)
    end

    def test_framework_names_lottie
        version_file = VersionFile.new(@lottie_path)
        assert_equal(['Lottie'], version_file.framework_names)
    end

    # number_of_frameworks

    def test_number_of_frameworks_lumberjack
        version_file = VersionFile.new(@lumberjack_path)
        assert_equal(8, version_file.number_of_frameworks)
    end

    def test_number_of_frameworks_lottie
        version_file = VersionFile.new(@lottie_path)
        assert_equal(1, version_file.number_of_frameworks)
    end

    # same_content?

    def test_same_content_with_same_file
        version_file = VersionFile.new(@lottie_path)
        assert_true(version_file.same_content?(version_file))
    end

    def test_same_content_with_nil
        version_file = VersionFile.new(@lottie_path)
        assert_false(version_file.same_content?(nil))
    end

    def test_same_content_with_different_file
        version_file1 = VersionFile.new(@lumberjack_path)
        version_file2 = VersionFile.new(@lottie_path)
        assert_false(version_file1.same_content?(version_file2))
    end

end
