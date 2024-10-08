# frozen_string_literal: true

require 'date'

class LongFormatter
  def format(base_directory)
    row_data = base_directory.file_attributes
    return 'total 0' if row_data.empty?

    total = "total #{base_directory.total_blocks}"
    max_sizes = base_directory.max_sizes
    body = format_body(row_data, max_sizes)
    [total, *body].join("\n")
  end

  private

  def format_body(row_data, max_sizes)
    row_data.map do |data|
      format_row(data, *max_sizes)
    end
  end

  def format_row(attribute, max_nlinks, max_user, max_group, max_size)
    [
      attribute.type_and_mode,
      "  #{attribute.nlinks.to_s.rjust(max_nlinks)}",
      " #{attribute.user_name.ljust(max_user)}",
      "  #{attribute.group_name.ljust(max_group)}",
      "  #{attribute.size.to_s.rjust(max_size)}",
      " #{format_timestamp(attribute.mtime)}",
      " #{attribute.file_name}"
    ].join
  end

  def format_timestamp(timestamp)
    if Date.parse(timestamp.to_s) > Date.today.prev_month(6)
      timestamp.strftime('%_2m %_2d %H:%M')
    else
      timestamp.strftime('%_2m %_2d %_5Y')
    end
  end
end
