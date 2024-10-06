# frozen_string_literal: true

class ShortFormatter
  COLUMN_WIDTH_UNIT = 8
  N_COLUMNS = 3

  def format(file_names)
    return '' if file_names.empty?

    max_name_length = file_names.map(&:size).max
    column_width = (max_name_length + 1).ceildiv(COLUMN_WIDTH_UNIT) * COLUMN_WIDTH_UNIT
    n_rows = file_names.size.ceildiv(N_COLUMNS)
    transposed_file_names = safe_transpose(file_names.each_slice(n_rows).to_a)
    to_text(transposed_file_names, column_width)
  end

  private

  def safe_transpose(nested_file_names)
    nested_file_names[0].zip(*nested_file_names[1..])
  end

  def to_text(file_names, column_width)
    file_names.map do |row_files|
      format_row(row_files, column_width)
    end.join("\n")
  end

  def format_row(row_files, column_width)
    row_files.map do |file_name|
      file_name.nil? ? '' : file_name.ljust(column_width)
    end.join.rstrip
  end
end
