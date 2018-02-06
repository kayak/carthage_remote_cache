require 'test/unit'
require 'carthage_remote_cache'

class UtilsTests < Test::Unit::TestCase

    # sh

    def test_sh
        output = sh('echo "Hello, world!"')
        assert_equal('Hello, world!', output)
    end

    # quote

    def test_quote_string
        assert_equal('', quote(''))
        assert_equal('"/some/path"', quote('/some/path'))
    end

    def test_quote_array
        assert_equal('', quote([]))
        assert_equal('"/some path1" "/some/path2" "/some_path3"', quote(['/some path1', '/some/path2', '/some_path3']))
    end

    def test_quote_unsupported
        assert_raises AppError do
            quote(1)
        end
    end

end
