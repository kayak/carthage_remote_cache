require "test/unit"
require "carthage_remote_cache"

class UtilsTests < Test::Unit::TestCase
  def setup
    @shell = ShellWrapper.new
  end

  def test_sh_success
    output = @shell.send(:sh, 'echo "Hello, world!"')
    assert_equal("Hello, world!", output)
  end

  def test_sh_failure
    assert_raises CmdError do
      @shell.send(:sh, "false")
    end
  end
end
