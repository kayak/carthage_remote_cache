require "test/unit"
require "carthage_remote_cache"
require "fixtures"

class UtilsTests < Test::Unit::TestCase

  # crc32

  def test_crc32
    checksum = crc32(Fixtures.framework1_version_path)
    # Get the expected value by running `crc32 test/fixtures/Build/.Framework1.version`
    assert_equal("cd8fa26b", checksum)
  end

  # quote

  def test_quote_string
    assert_equal("", quote(""))
    assert_equal('"/some/path"', quote("/some/path"))
  end

  def test_quote_array
    assert_equal("", quote([]))
    assert_equal('"/some path1" "/some/path2" "/some_path3"', quote(["/some path1", "/some/path2", "/some_path3"]))
  end

  def test_quote_unsupported
    assert_raises AppError do
      quote(1)
    end
  end

  # format_file_size

  def test_format_file_size
    assert_equal("0.0 MB", format_file_size(0))
    assert_equal("0.1 MB", format_file_size(1))
    assert_equal("0.1 MB", format_file_size(1000 * 100))
    assert_equal("1.0 MB", format_file_size(1000 * 1000))
    assert_equal("10.0 MB", format_file_size(1000 * 1000 * 10))
  end
end
