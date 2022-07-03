require "test/unit"
require "carthage_remote_cache"
require "fixtures"
require "mocha/test_unit"

class XCFrameworkCarthageArchiveTests < Test::Unit::TestCase
  def test_compress_archive
    shell = mock("shell")

    archive_side_effect = CreateArchiveSideEffect.new
    shell
      .expects(:archive)
      .with(fixtures_expected_input_archive_paths, "SuperAwesome-iOS.zip")
      .add_side_effect(archive_side_effect)

    archive = XCFrameworkCarthageArchive.new("SuperAwesome", :iOS)
    begin
      archive.compress_archive(shell, FIXTURES_BUILD_DIR)
      assert_true(File.exist?("SuperAwesome-iOS.zip"))
      assert_equal(5, archive.archive_size)
    ensure
      archive_side_effect.cleanup
    end
  end

  def test_compress_archive_invalid_framework
    archive = XCFrameworkCarthageArchive.new("InvalidFramework", :iOS)
    assert_raises MissingFrameworkDirectoryError do
      archive.compress_archive(nil, FIXTURES_BUILD_DIR)
    end
  end

  private

  def fixtures_expected_input_archive_paths
    [
      Fixtures.xcframework_dir_path,
    ]
  end

  class CreateArchiveSideEffect
    def perform
      File.write("SuperAwesome-iOS.zip", "12345")
    end

    def cleanup
      File.delete("SuperAwesome-iOS.zip")
    end
  end
end
