require 'test/unit'
require 'carthage_remote_cache'
require 'fixtures'
require 'mocha/test_unit'

class CarthageArchiveTests < Test::Unit::TestCase
  def test_create_archive
    shell = mock('shell')

    shell
      .expects(:dwarfdump)
      .with(includes('test/fixtures/Build/iOS/Framework1.framework/Framework1'))
      .returns(fixture_dwarf_response)

    archive_side_effect = CreateArchiveSideEffect.new
    shell
      .expects(:archive)
      .with(fixtures_expected_input_archive_paths, 'Framework1-iOS.zip')
      .add_side_effect(archive_side_effect)

    archive = CarthageArchive.new('Framework1', :iOS)
    begin
      archive.create_archive(shell, should_include_dsym = true, FIXTURES_BUILD_DIR)
      assert_true(File.exist?('Framework1-iOS.zip'))
      assert_equal(5, archive.archive_size)
    ensure
      archive_side_effect.cleanup
    end
  end

  def test_create_archive_invalid_framework
    archive = CarthageArchive.new('InvalidFramework', :iOS)
    assert_raises MissingFrameworkDirectoryError do
      archive.create_archive(nil, should_include_dsym = true, FIXTURES_BUILD_DIR)
    end
  end

  private

  def fixture_dwarf_response
    <<~EOS
      UUID: #{Fixtures.bcsymbolmap_A0F_uuid} (i386) fixtures/Build/iOS/Framework1.framework/Framework
      UUID: #{Fixtures.bcsymbolmap_A66_uuid} (x86_64) fixtures/Build/iOS/Framework1.framework/Framework
      UUID: #{Fixtures.bcsymbolmap_invalid_uuid} (armv7) fixtures/Build/iOS/Framework1.framework/Framework
    EOS
  end

  def fixtures_expected_input_archive_paths
    [
      Fixtures.framework1_dir_path,
      Fixtures.framework1_dsym_path,
      Fixtures.bcsymbolmap_A0F_path,
      Fixtures.bcsymbolmap_A66_path,
    ]
  end

  class CreateArchiveSideEffect
    def perform
      File.write('Framework1-iOS.zip', '12345')
    end

    def cleanup
      File.delete('Framework1-iOS.zip')
    end
  end
end
