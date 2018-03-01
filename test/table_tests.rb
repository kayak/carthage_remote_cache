require 'test/unit'
require 'carthage_remote_cache'

class TableTests < Test::Unit::TestCase
  def test_table_empty_rows
    header = ["N/A"]
    rows = []

    table = Table.new(header, rows)
    expected = <<~EOS
      +-----+
      | N/A |
      +-----+
      +-----+
    EOS
    assert_equal(expected.chomp, table.to_s)
  end

  def test_table_1
    header = ["A", "B", "C"]
    rows = [
      ["Hello", "Longer Text", "0"],
      ["World", "Short", "1000"],
      ["!", "?", ""],
    ]

    table = Table.new(header, rows)
    expected = <<~EOS
      +-------+-------------+------+
      | A     | B           | C    |
      +-------+-------------+------+
      | Hello | Longer Text |    0 |
      | World |       Short | 1000 |
      | !     |           ? |      |
      +-------+-------------+------+
    EOS
    assert_equal(expected.chomp, table.to_s)
  end

  def test_table_2
    header = ["Framework", "Carthage/Build", "Cartfile.resolved"]
    rows = [
      ["SomeFramework", "1.0", "1.1"],
      ["Another", "22", "23"],
    ]

    table = Table.new(header, rows)
    expected = <<~EOS
      +---------------+----------------+-------------------+
      | Framework     | Carthage/Build | Cartfile.resolved |
      +---------------+----------------+-------------------+
      | SomeFramework |            1.0 |               1.1 |
      | Another       |             22 |                23 |
      +---------------+----------------+-------------------+
    EOS
    assert_equal(expected.chomp, table.to_s)
  end
end
