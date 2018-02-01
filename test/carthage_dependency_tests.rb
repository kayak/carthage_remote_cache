require 'test/unit'
require 'carthage_remote_cache'

class CarthageDependencyTests < Test::Unit::TestCase

    def test_parse_version
        d = CarthageDependency.parse_cartfile_resolved_line('github "yada/lada" "1.2.3"')
        assert_equal('github', d.type)
        assert_equal('yada/lada', d.repository)
        assert_equal('1.2.3', d.version)
    end

    def test_parse_without_version
        d = CarthageDependency.parse_cartfile_resolved_line('github "yada/lada"')
        assert_equal(nil, d)
    end

end
