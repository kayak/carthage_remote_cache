require "test/unit"
require "carthage_remote_cache"
require "fixtures"

class CarthageDependencyTests < Test::Unit::TestCase

  #  parse_cartfile_resolved_line

  def test_parse_cartfile_resolved_line_github
    carthage_dependency = CarthageDependency.parse_cartfile_resolved_line('github "yada/lada" "1.2.3"')
    assert_equal(:github, carthage_dependency.origin)
    assert_equal("yada/lada", carthage_dependency.source)
    assert_equal("1.2.3", carthage_dependency.version)
  end

  def test_parse_cartfile_resolved_line_git
    carthage_dependency = CarthageDependency.parse_cartfile_resolved_line('git "file:///Users/someone/MyFramework" "master"')
    assert_equal(:git, carthage_dependency.origin)
    assert_equal("file:///Users/someone/MyFramework", carthage_dependency.source)
    assert_equal("master", carthage_dependency.version)
  end

  def test_parse_cartfile_resolved_line_binary
    carthage_dependency = CarthageDependency.parse_cartfile_resolved_line('binary "https://my.domain.com/release/MyFramework.json" "2.3"')
    assert_equal(:binary, carthage_dependency.origin)
    assert_equal("https://my.domain.com/release/MyFramework.json", carthage_dependency.source)
    assert_equal("2.3", carthage_dependency.version)
  end

  def test_parse_cartfile_resolved_line_without_version
    carthage_dependency = CarthageDependency.parse_cartfile_resolved_line('github "yada/lada"')
    assert_equal(nil, carthage_dependency)
  end

  # guessed_framework_basename && version_filename

  def test_framework_name_github
    carthage_dependency = CarthageDependency.new(:origin => :github, :source => "hello/baddie", :version => "2.1.6")
    assert_equal("baddie", carthage_dependency.guessed_framework_basename)
    assert_equal(".baddie.version", carthage_dependency.version_filename)
  end

  def test_framework_name_git
    carthage_dependency = CarthageDependency.new(:origin => :git, :source => "file:///Users/someone/MyFramework.git", :version => "2.1.6")
    assert_equal("MyFramework", carthage_dependency.guessed_framework_basename)
    assert_equal(".MyFramework.version", carthage_dependency.version_filename)
  end

  def test_framework_name_git_no_extension
    carthage_dependency = CarthageDependency.new(:origin => :git, :source => "file:///Users/someone/MyFramework", :version => "1.2.3")
    assert_equal("MyFramework", carthage_dependency.guessed_framework_basename)
    assert_equal(".MyFramework.version", carthage_dependency.version_filename)
  end

  def test_framework_name_git_different_extension
    carthage_dependency = CarthageDependency.new(:origin => :git, :source => "file:///Users/someone/MyFramework.repo", :version => "1.2.3")
    assert_equal("MyFramework.repo", carthage_dependency.guessed_framework_basename)
    assert_equal(".MyFramework.repo.version", carthage_dependency.version_filename)
  end

  def test_version_filename_binary
    carthage_dependency = CarthageDependency.new(:origin => :binary, :source => "https://my.domain.com/release/MyFramework.json", :version => "2.3")
    assert_equal("MyFramework", carthage_dependency.guessed_framework_basename)
    assert_equal(".MyFramework.version", carthage_dependency.version_filename)
  end

  def test_version_filename_binary_no_extension
    carthage_dependency = CarthageDependency.new(:origin => :binary, :source => "https://my.domain.com/release/MyFramework", :version => "2.3")
    assert_equal("MyFramework", carthage_dependency.guessed_framework_basename)
    assert_equal(".MyFramework.version", carthage_dependency.version_filename)
  end

  def test_version_filename_binary_different_extension
    carthage_dependency = CarthageDependency.new(:origin => :binary, :source => "https://my.domain.com/release/MyFramework.txt", :version => "2.3")
    assert_equal("MyFramework.txt", carthage_dependency.guessed_framework_basename)
    assert_equal(".MyFramework.txt.version", carthage_dependency.version_filename)
  end

  # verify_version_in_version_file

  def test_verify_version_in_version_file_success
    carthage_dependency = CarthageDependency.new(:origin => :github, :source => "hello/baddie", :version => "2.1.6")
    assert_nothing_raised do
      carthage_dependency.verify_version_in_version_file(Fixtures.baddie_version_file)
    end
  end

  def test_verify_version_in_version_file_outdated_build_version
    carthage_dependency = CarthageDependency.new(:origin => :github, :source => "hello/baddie", :version => "2.1.8")
    assert_raises OutdatedFrameworkBuildError.new("baddie", "2.1.6", "2.1.8") do
      carthage_dependency.verify_version_in_version_file(Fixtures.baddie_version_file)
    end
  end
end
