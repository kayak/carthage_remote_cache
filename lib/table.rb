class Table
  def initialize(header, rows)
    @header = header
    @rows = rows
    @column_sizes = calculate_column_sizes
  end

  def to_s
    lines = [
      separator_line,
      header_line,
      separator_line,
      @rows.map { |r| row_line(r) },
      separator_line,
    ]

    lines
      .flatten
      .reject { |line| line.empty? }
      .join("\n")
  end

  private

  def calculate_column_sizes
    all = [@header] + @rows
    result = all.transpose.map do |row|
      lengths = row.map { |r| r.length }
      lengths.max + 2
    end
    result
  end

  def separator_line
    dashes = @column_sizes.map { |size| "-" * size }
    "+" + dashes.join("+") + "+"
  end

  def header_line
    columns = @header.each_with_index.map do |column, index|
      column_size = @column_sizes[index] - 1
      " %-#{column_size}.#{column_size}s" % column
    end
    "|" + columns.join("|") + "|"
  end

  def row_line(row)
    columns = row.each_with_index.map do |column, index|
      column_size = @column_sizes[index] - 1
      if index == 0
        " %-#{column_size}.#{column_size}s" % column
      else
        "%#{column_size}.#{column_size}s " % column
      end
    end
    "|" + columns.join("|") + "|"
  end
end
