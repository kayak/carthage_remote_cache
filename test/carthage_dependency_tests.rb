require 'test/unit'
require 'carthage_remote_cache'
require 'fixtures'

class CarthageDependencyTests < Test::Unit::TestCase

  #  parse_cartfile_resolved_line

  def test_parse_version
    carthage_dependency = CarthageDependency.parse_cartfile_resolved_line('github "yada/lada" "1.2.3"')
    assert_equal('github', carthage_dependency.type)
    assert_equal('yada/lada', carthage_dependency.repository)
    assert_equal('1.2.3', carthage_dependency.version)
  end

  def test_parse_without_version
    carthage_dependency = CarthageDependency.parse_cartfile_resolved_line('github "yada/lada"')
    assert_equal(nil, carthage_dependency)
  end

  def test_version_filename
    carthage_dependency = CarthageDependency.parse_cartfile_resolved_line('github "yada/lada" "1.2.3"')
    assert_equal('.lada.version', carthage_dependency.version_filename)
  end

  # validate_version_file

  def test_validate_version_file_success
    carthage_dependency = CarthageDependency.new(:type => 'github', :repository => 'hello/baddie', :version => '2.1.6')
    assert_nothing_raised do
      carthage_dependency.validate_version_file(Fixtures.baddie_version_file)
    end
  end

  def test_validate_version_file_outdated_build_version
    carthage_dependency = CarthageDependency.new(:type => 'github', :repository => 'hello/baddie', :version => '2.1.8')
    assert_raises OutdatedFrameworkBuildError do
      carthage_dependency.validate_version_file(Fixtures.baddie_version_file)
    end
  end
end
