# frozen_string_literal: true

require 'date'

class LongFormatter
  def format(base_directory)
    files = base_directory.files
    total = "total #{base_directory.total_blocks}"
    max_sizes = base_directory.max_sizes
    body = format_body(files, max_sizes)
    [total, *body].join("\n")
  end

  private

  def format_body(files, max_sizes)
    files.map do |file|
      format_row(file, *max_sizes)
    end
  end

  def format_row(file, max_nlinks, max_user, max_group, max_size)
    [
      file.type_and_mode,
      "  #{file.nlinks.to_s.rjust(max_nlinks)}",
      " #{file.user_name.ljust(max_user)}",
      "  #{file.group_name.ljust(max_group)}",
      "  #{file.size.to_s.rjust(max_size)}",
      " #{format_timestamp(file.mtime)}",
      " #{file.name}"
    ].join
  end

  def format_timestamp(timestamp)
    if Date.parse(timestamp.to_s) > Date.today.prev_month(6)
      timestamp.strftime('%b %_2d %H:%M')
    else
      timestamp.strftime('%b %_2d %_5Y')
    end
  end
end
