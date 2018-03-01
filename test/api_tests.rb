require 'test/unit'
require 'carthage_remote_cache'
require 'fixtures'
require 'tempfile'
require 'mocha/test_unit'

class APITests < Test::Unit::TestCase
  def setup
    @shell = mock()
    @config = mock()
    @networking = mock()
    @options = {}
    @api = API.new(@shell, @config, @networking, @options)
  end

  # @!group verify_server_version

  def test_server_returns_same_version
    @networking.expects(:get_server_version).returns(VERSION)
    assert_nothing_raised do
      @api.verify_server_version
    end
  end

  def test_server_returns_different_version
    @networking.expects(:get_server_version).returns('0.0.1')
    assert_raises ServerVersionMismatchError do
      @api.verify_server_version
    end
  end

  # @!group version_file_matches_server?

  def test_version_file_never_matches_server_when_forced
    @options[:force] = true
    assert_false(@api.version_file_matches_server?(nil, nil))
  end

  def test_version_file_matches_server
    carthage_dependency = CarthageDependency.new(:origin => :github, :source => 'hello/baddie', :version => '2.1.6')
    version_file = Fixtures.baddie_version_file

    with_temporary_server_version_from_path(version_file.path) do |server_version_file|
      @networking.expects(:download_version_file).with(carthage_dependency).returns(server_version_file)
      assert_true(@api.version_file_matches_server?(carthage_dependency, version_file))
    end
  end

  def test_version_file_doesnt_match_server
    carthage_dependency = CarthageDependency.new(:origin => :github, :source => 'hello/baddie', :version => '2.1.6')
    version_file = Fixtures.baddie_version_file

    with_temporary_server_version_from_path(Fixtures.framework1_version_path) do |server_version_file|
      @networking.expects(:download_version_file).with(carthage_dependency).returns(server_version_file)
      assert_false(@api.version_file_matches_server?(carthage_dependency, version_file))
    end
  end

  private

  def with_temporary_server_version_from_path(path)
    file = Tempfile.new('.tmpfile.version')
    file.write(File.read(path))
    file.close

    server_version_file = VersionFile.new(file.path)

    begin
      yield server_version_file
    ensure
      file.unlink
    end
  end
end
