require "test/unit"
require "carthage_remote_cache"
require "fixtures"

class VersionFileTests < Test::Unit::TestCase

  # initialize

  def test_framework_does_not_exist
    assert_raises VersionFileDoesNotExistError do
      Fixtures.nonexistent_version_file
    end
  end

  def test_init_lumberjack
    version_file = Fixtures.lumberjack_version_file
    assert_equal(2, version_file.json["iOS"].count)
    assert_equal(2, version_file.json["Mac"].count)
    assert_equal(2, version_file.json["tvOS"].count)
    assert_equal(2, version_file.json["watchOS"].count)
  end

  def test_init_lumberjack_filtered_platforms
    version_file = Fixtures.lumberjack_version_file([:iOS])
    assert_equal(2, version_file.json["iOS"].count)
    assert_equal(0, version_file.json["Mac"].count)
    assert_equal(0, version_file.json["tvOS"].count)
    assert_equal(0, version_file.json["watchOS"].count)
  end

  def test_init_xcframework
    version_file = Fixtures.xcframework_version_file
    assert_equal(3, version_file.json["iOS"].count)
    assert_equal(0, version_file.json["Mac"].count)
    assert_equal(0, version_file.json["tvOS"].count)
    assert_equal(0, version_file.json["watchOS"].count)
  end

  # version

  def test_version_lumberjack
    version_file = Fixtures.lumberjack_version_file
    assert_equal("3.7.4", version_file.version)
  end

  def test_version_baddie
    version_file = Fixtures.baddie_version_file
    assert_equal("2.1.6", version_file.version)
  end

  def test_version_xcframework
    version_file = Fixtures.xcframework_version_file
    assert_equal("1.0.0", version_file.version)
  end

  # frameworks_by_platform

  def test_frameworks_by_platform_xcframework
    version_file = Fixtures.xcframework_version_file
    assert_equal(version_file.frameworks_by_platform, {
      :iOS => [
        XCFramework.new(
          "SuperAwesome",
          "SuperAwesome.xcframework",
          ["ios-arm64_i386_x86_64-simulator", "ios-arm64_x86_64-maccatalyst", "ios-arm64_armv7"]
        ),
      ],
      :macOS => [],
      :tvOS => [],
      :watchOS => [],
    })
  end

  # framework_names_by_platform

  def test_framework_names_by_platform_lumberjack
    version_file = Fixtures.lumberjack_version_file
    assert_equal(version_file.framework_names_by_platform, {
      :iOS => ["CocoaLumberjack", "CocoaLumberjackSwift"],
      :macOS => ["CocoaLumberjack", "CocoaLumberjackSwift"],
      :tvOS => ["CocoaLumberjack", "CocoaLumberjackSwift"],
      :watchOS => ["CocoaLumberjack", "CocoaLumberjackSwift"],
    })
  end

  def test_framework_names_by_platform_lumberjack_filtered_platforms
    version_file = Fixtures.lumberjack_version_file([:iOS])
    assert_equal(version_file.framework_names_by_platform, {
      :iOS => ["CocoaLumberjack", "CocoaLumberjackSwift"],
      :macOS => [],
      :tvOS => [],
      :watchOS => [],
    })
  end

  def test_framework_names_by_platform_baddie
    version_file = Fixtures.baddie_version_file
    assert_equal(version_file.framework_names_by_platform, {
      :iOS => ["Baddie"],
      :macOS => [],
      :tvOS => [],
      :watchOS => [],
    })
  end

  def test_framework_names_by_platform_xcframework
    version_file = Fixtures.xcframework_version_file
    assert_equal(version_file.framework_names_by_platform, {
      :iOS => ["SuperAwesome"],
      :macOS => [],
      :tvOS => [],
      :watchOS => [],
    })
  end

  # platforms_by_framework

  def test_platforms_by_framework_lumberjack
    version_file = Fixtures.lumberjack_version_file
    assert_equal(version_file.platforms_by_framework, {
      "CocoaLumberjack" => [:iOS, :macOS, :tvOS, :watchOS],
      "CocoaLumberjackSwift" => [:iOS, :macOS, :tvOS, :watchOS],
    })
  end

  def test_platforms_by_framework_lumberjack_filtered_platforms
    version_file = Fixtures.lumberjack_version_file([:iOS])
    assert_equal(version_file.platforms_by_framework, {
      "CocoaLumberjack" => [:iOS],
      "CocoaLumberjackSwift" => [:iOS],
    })
  end

  def test_platforms_by_framework_baddie
    version_file = Fixtures.baddie_version_file
    assert_equal(version_file.platforms_by_framework, { "Baddie" => [:iOS] })
  end

  def test_platforms_by_framework_xcframework_filtered_platforms
    version_file = Fixtures.xcframework_version_file([:iOS])
    assert_equal(version_file.platforms_by_framework, {
      "SuperAwesome" => [:iOS],
    })
  end

  # framework_names

  def test_framework_names_lumberjack
    version_file = Fixtures.lumberjack_version_file
    assert_equal(["CocoaLumberjack", "CocoaLumberjackSwift"], version_file.framework_names)
  end

  def test_framework_names_baddie
    version_file = Fixtures.baddie_version_file
    assert_equal(["Baddie"], version_file.framework_names)
  end

  def test_framework_names_xcframework
    version_file = Fixtures.xcframework_version_file
    assert_equal(["SuperAwesome"], version_file.framework_names)
  end

  # number_of_frameworks

  def test_number_of_frameworks_lumberjack
    version_file = Fixtures.lumberjack_version_file
    assert_equal(8, version_file.number_of_frameworks)
  end

  def test_number_of_frameworks_baddie
    version_file = Fixtures.baddie_version_file
    assert_equal(1, version_file.number_of_frameworks)
  end

  def test_number_of_frameworks_xcframework
    version_file = Fixtures.xcframework_version_file
    assert_equal(1, version_file.number_of_frameworks)
  end

  # same_content?

  def test_same_content_with_same_file
    version_file = Fixtures.baddie_version_file
    assert_true(version_file.same_content?(version_file))
  end

  def test_same_content_with_nil
    version_file = Fixtures.baddie_version_file
    assert_false(version_file.same_content?(nil))
  end

  def test_same_content_with_different_file
    version_file1 = Fixtures.lumberjack_version_file
    version_file2 = Fixtures.baddie_version_file
    assert_false(version_file1.same_content?(version_file2))
  end

  def test_same_content_with_same_file_and_platforms
    for platform in PLATFORMS
      version_file = Fixtures.lumberjack_version_file([platform])
      assert_true(version_file.same_content?(version_file))
    end
  end

  def test_same_content_with_same_file_and_different_platforms
    version_file1 = Fixtures.lumberjack_version_file([:iOS])
    version_file2 = Fixtures.lumberjack_version_file([:watchOS])
    assert_false(version_file1.same_content?(version_file2))
  end
end
