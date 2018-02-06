require 'test/unit'
require 'carthage_remote_cache'
require 'fixtures'

class VersionFileTests < Test::Unit::TestCase

  # version

  def test_version_lumberjack
    version_file = Fixtures.lumberjack_version_file
    assert_equal('3.2.1', version_file.version)
  end

  def test_version_baddie
    version_file = Fixtures.baddie_version_file
    assert_equal('2.1.6', version_file.version)
  end

  # frameworks_by_platform

  def test_frameworks_by_platform_lumberjack
    version_file = Fixtures.lumberjack_version_file
    assert_equal(version_file.frameworks_by_platform, {
      :iOS => ['LumberjackSwift', 'Lumberjack'],
      :macOS => ['LumberjackSwift', 'Lumberjack'],
      :tvOS => ['LumberjackSwift', 'Lumberjack'],
      :watchOS => ['LumberjackSwift', 'Lumberjack'],
    })
  end

  def test_frameworks_by_platform_baddie
    version_file = Fixtures.baddie_version_file
    assert_equal(version_file.frameworks_by_platform, {
      :iOS => ['Baddie'],
      :macOS => [],
      :tvOS => [],
      :watchOS => [],
    })
  end

  # platforms_by_framework

  def test_platforms_by_framework_lumberjack
    version_file = Fixtures.lumberjack_version_file
    assert_equal(version_file.platforms_by_framework, {
      'Lumberjack' => [:iOS, :macOS, :tvOS, :watchOS],
      'LumberjackSwift' => [:iOS, :macOS, :tvOS, :watchOS],
    })
  end

  def test_platforms_by_framework_baddie
    version_file = Fixtures.baddie_version_file
    assert_equal(version_file.platforms_by_framework, {'Baddie' => [:iOS]})
  end

  # framework_names

  def test_framework_names_lumberjack
    version_file = Fixtures.lumberjack_version_file
    assert_equal(['Lumberjack', 'LumberjackSwift'], version_file.framework_names)
  end

  def test_framework_names_baddie
    version_file = Fixtures.baddie_version_file
    assert_equal(['Baddie'], version_file.framework_names)
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
end
