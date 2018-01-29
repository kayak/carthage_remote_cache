require 'test/unit'
require_relative '../lib/carthage_dependency'
require_relative '../lib/configuration'

class CarthageDependencyTests < Test::Unit::TestCase

    def test_parse_exact
        d = CarthageDependency.parse('github "yada/lada" "1.2.3"')
        assert_equal('github', d.type)
        assert_equal('yada/lada', d.repository)
        assert_equal('1.2.3', d.version)
    end

    def test_parse_latest
        d = CarthageDependency.parse('github "yada/lada"')
        assert_equal('github', d.type)
        assert_equal('yada/lada', d.repository)
        assert_equal(nil, d.version)
    end

    def test_framework_names
        # TODO
        # d = CarthageDependency.new(type: 'github', repository: 'yada/lada', version: '1.2.3')
        # d.framework_names
    end

end
