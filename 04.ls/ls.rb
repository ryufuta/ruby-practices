#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'etc'
require 'optparse'

COLUMN_WIDTH_UNIT = 8
N_COLUMNS = 3

def main
  options = ARGV.getopts('alr')
  file_names = options['a'] ? Dir.entries('.').sort : Dir.glob('*')
  file_names = file_names.reverse if options['r']

  if options['l']
    return puts 'total 0' if file_names.empty?

    puts to_ls_l_text(file_names)
  else
    return if file_names.empty?

    file_names = justify_columns(file_names)
    puts to_ls_text(file_names)
  end
end

def to_ls_l_text(file_names)
  attributes_by_file = file_names.map { |file_name| fetch_file_attributes(file_name) }
  attributes_by_type = attributes_by_file.transpose
  total_blocks = attributes_by_type[0].sum
  max_digit_links = attributes_by_type[3].max.to_s.size
  max_owner_name_length = attributes_by_type[4].map(&:size).max
  max_group_name_length = attributes_by_type[5].map(&:size).max
  max_digit_file_size = attributes_by_type[6].max.to_s.size

  attributes_by_file.sum("total #{total_blocks}\n") do |file_attributes|
    "#{file_attributes[1]}#{file_attributes[2] || ' '} "\
    "#{file_attributes[3].to_s.rjust(max_digit_links)} "\
    "#{file_attributes[4].ljust(max_owner_name_length)}  "\
    "#{file_attributes[5].ljust(max_group_name_length)}  "\
    "#{file_attributes[6].to_s.rjust(max_digit_file_size)} "\
    "#{file_attributes[7]} "\
    "#{file_attributes[8]}\n"
  end
end

def fetch_file_attributes(file_name)
  file_attributes = File.lstat(file_name)
  [
    file_attributes.blocks,
    to_symbolic_notation(file_attributes.mode),
    `xattr -s #{file_name}`.empty? ? nil : '@',
    file_attributes.nlink,
    Etc.getpwuid(file_attributes.uid).name,
    Etc.getgrgid(file_attributes.gid).name,
    file_attributes.size,
    format_timestamp(file_attributes.mtime),
    file_attributes.symlink? ? "#{file_name} -> #{File.readlink(file_name)}" : file_name
  ]
end

def to_symbolic_notation(mode)
  mode_text = mode.to_s(8).rjust(6, '0')
  file_type_oct_to_symbolic = {
    '01' => 'p',
    '02' => 'c',
    '04' => 'd',
    '06' => 'b',
    '10' => '-',
    '12' => 'l',
    '14' => 's'
  }
  file_type = file_type_oct_to_symbolic[mode_text[0, 2]]

  permission_oct_to_symbolic = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }
  owner_permission = permission_oct_to_symbolic[mode_text[3]]
  group_permission = permission_oct_to_symbolic[mode_text[4]]
  other_permission = permission_oct_to_symbolic[mode_text[5]]

  case mode_text[2]
  when '1'
    other_permission = other_permission[0, 2] + (other_permission[2] == 'x' ? 't' : 'T')
  when '2'
    group_permission = group_permission[0, 2] + (group_permission[2] == 'x' ? 's' : 'S')
  when '4'
    owner_permission = owner_permission[0, 2] + (owner_permission[2] == 'x' ? 's' : 'S')
  end

  file_type + owner_permission + group_permission + other_permission
end

def format_timestamp(timestamp)
  if Date.parse(timestamp.to_s) > Date.today.prev_month(6)
    timestamp.strftime('%_2m %_2d %H:%M')
  else
    timestamp.strftime('%_2m %_2d %_5Y')
  end
end

def justify_columns(file_names)
  # 全角文字は2文字分カウント
  file_names_with_length = file_names.map { |file_name| [file_name, file_name.size + count_full_width_chars(file_name)] }
  max_name_length = file_names_with_length.map { |_, length| length }.max

  column_width = (max_name_length + 1).ceildiv(COLUMN_WIDTH_UNIT) * COLUMN_WIDTH_UNIT

  # 全角文字は2文字分の幅のためその分短くする
  file_names_with_length.map { |file_name, length| file_name.ljust(column_width - length + file_name.size) }
end

def count_full_width_chars(str)
  str.scan(/[^\x01-\x7E\uFF65-\uFF9F]/).size
end

def to_ls_text(file_names)
  # ファイル数が列数の倍数になるように末尾に空文字追加
  file_names += [''] * (file_names.size.ceildiv(N_COLUMNS) * N_COLUMNS - file_names.size)

  # 上から下、左から右へ昇順、指定した列数になるように表示
  ls_text = ''
  n_rows = file_names.size / N_COLUMNS
  n_rows.times do |row|
    N_COLUMNS.times { |col| ls_text += file_names[row + n_rows * col] }
    ls_text += "\n"
  end
  ls_text
end

main if __FILE__ == $PROGRAM_NAME
