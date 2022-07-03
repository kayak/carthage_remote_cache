FIXTURES_DIR = File.expand_path("../fixtures", __FILE__)
FIXTURES_BUILD_DIR = File.join(FIXTURES_DIR, "Build")
FIXTURES_BUILD_IOS_DIR = File.join(FIXTURES_BUILD_DIR, "iOS")

class Fixtures
  class << self

    # @!group nonexistent

    def nonexistent_version_file
      VersionFile.new(nonexistent_version_file_path)
    end

    def nonexistent_version_file_path
      File.join(FIXTURES_BUILD_DIR, ".nonexistent.version")
    end

    # @!group lumberjack

    def lumberjack_version_file(platforms = PLATFORMS)
      VersionFile.new(lumberjack_version_path, platforms)
    end

    def lumberjack_version_path
      File.join(FIXTURES_BUILD_DIR, ".lumberjack.version")
    end

    # @!group baddie

    def baddie_version_file
      VersionFile.new(baddie_version_path)
    end

    def baddie_version_path
      File.join(FIXTURES_BUILD_DIR, ".baddie.version")
    end

    # @!group Framework1

    def framework1_version_path
      File.join(FIXTURES_BUILD_DIR, ".Framework1.version")
    end

    def framework1_dir_path
      File.join(FIXTURES_BUILD_IOS_DIR, "Framework1.framework")
    end

    def framework1_dsym_path
      File.join(FIXTURES_BUILD_IOS_DIR, "Framework1.framework.dSYM")
    end

    def bcsymbolmap_A0F_path
      File.join(FIXTURES_BUILD_IOS_DIR, bcsymbolmap_A0F_uuid + ".bcsymbolmap")
    end

    def bcsymbolmap_A66_path
      File.join(FIXTURES_BUILD_IOS_DIR, bcsymbolmap_A66_uuid + ".bcsymbolmap")
    end

    def bcsymbolmap_A0F_uuid
      "A0F30CB0-3A0D-33A7-B149-020251A1E1A4"
    end

    def bcsymbolmap_A66_uuid
      "A663617F-D848-37DF-AB4B-6A35F51E005A"
    end

    def bcsymbolmap_invalid_uuid
      "XXXXXXXX-D848-37DF-AB4B-6A35F51E005A"
    end

    # @!group XCFramework

    def xcframework_version_file(platforms = PLATFORMS)
      VersionFile.new(xcframework_version_path, platforms)
    end

    def xcframework_version_path
      File.join(FIXTURES_BUILD_DIR, ".XCFramework.version")
    end

    def xcframework_dir_path
      File.join(FIXTURES_BUILD_DIR, "SuperAwesome.xcframework")
    end
  end
end
