#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'etc'
require 'optparse'
require 'open3'

COLUMN_WIDTH_UNIT = 8
N_COLUMNS = 3
FILE_TYPE_OCT_TO_SYMBOLIC = {
  '01' => 'p',
  '02' => 'c',
  '04' => 'd',
  '06' => 'b',
  '10' => '-',
  '12' => 'l',
  '14' => 's'
}.freeze
PERMISSION_OCT_TO_SYMBOLIC = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

FileAttribute = Data.define(:blocks, :file_type_with_permissions, :xattr, :nlinks, :owner_name, :group_name, :size, :updated_at, :file_name)

def main
  options = ARGV.getopts('alr')
  if ARGV.empty?
    file_names = options['a'] ? Dir.entries('.').sort : Dir.glob('*')
    file_names = file_names.reverse if options['r']
    if options['l']
      return puts 'total 0' if file_names.empty?

      puts to_ls_l_text(file_names)
    else
      return if file_names.empty?

      puts to_ls_text(file_names)
    end
  else
    file_paths_not_found = []
    file_paths = []
    file_names_by_dir = {}
    ARGV.each do |path|
      if File.exist?(path)
        if File.directory?(path)
          file_names = Dir.entries(path).sort
          file_names = file_names.reject { |file_name| file_name[0] == '.' } unless options['a']
          file_names = file_names.reverse if options['r']
          file_names_by_dir[path] = file_names
        else
          file_paths << path
        end
      else
        file_paths_not_found << path
      end
    end

    file_paths_not_found = file_paths_not_found.sort
    file_paths = file_paths.sort
    file_names_by_dir = file_names_by_dir.sort.to_h
    if options['r']
      file_paths = file_paths.reverse
      file_names_by_dir = file_names_by_dir.to_a.reverse.to_h
    end

    ls_text = ''
    ls_text += "#{to_ls_not_found_text(file_paths_not_found)}\n" unless file_paths_not_found.empty?
    ls_text += "#{to_ls_text(file_paths)}\n\n" unless file_paths.empty?
    if ls_text.empty? && file_names_by_dir.size == 1
      ls_text = to_ls_text(file_names_by_dir.values[0])
    elsif !file_names_by_dir.empty?
      ls_text += file_names_by_dir.map { |dir_path, file_names| "#{dir_path}:\n#{to_ls_text(file_names)}" }.join("\n\n")
    end

    puts ls_text.rstrip
  end
end

def to_ls_l_text(file_names)
  xattr_found = system('which xattr', out: '/dev/null', err: '/dev/null')
  attributes_by_file = file_names.map { |file_name| fetch_file_attributes(file_name, xattr_found) }
  total_blocks, max_digit_links, max_owner_name_length, max_group_name_length, max_digit_file_size =
    calculate_total_blocks_and_column_widths(attributes_by_file)
  "total #{total_blocks}\n" + attributes_by_file.map do |file_attributes|
    "#{file_attributes.file_type_with_permissions}#{file_attributes.xattr || ' '} "\
    "#{file_attributes.nlinks.to_s.rjust(max_digit_links)} "\
    "#{file_attributes.owner_name.ljust(max_owner_name_length)}  "\
    "#{file_attributes.group_name.ljust(max_group_name_length)}  "\
    "#{file_attributes.size.to_s.rjust(max_digit_file_size)} "\
    "#{file_attributes.updated_at} "\
    "#{file_attributes.file_name}"
  end.join("\n")
end

def fetch_file_attributes(file_name, xattr_found)
  file_attributes = File.lstat(file_name)
  FileAttribute.new(
    file_attributes.blocks,
    to_symbolic_notation(file_attributes.mode),
    xattr_found && !Open3.capture3("xattr -s #{file_name}")[0].empty? ? '@' : nil,
    file_attributes.nlink,
    Etc.getpwuid(file_attributes.uid).name,
    Etc.getgrgid(file_attributes.gid).name,
    file_attributes.size,
    format_timestamp(file_attributes.mtime),
    file_attributes.symlink? ? "#{file_name} -> #{File.readlink(file_name)}" : file_name
  )
end

def to_symbolic_notation(mode)
  mode_text = mode.to_s(8).rjust(6, '0')
  file_type = FILE_TYPE_OCT_TO_SYMBOLIC[mode_text[0, 2]]
  owner_permission = PERMISSION_OCT_TO_SYMBOLIC[mode_text[3]]
  group_permission = PERMISSION_OCT_TO_SYMBOLIC[mode_text[4]]
  other_permission = PERMISSION_OCT_TO_SYMBOLIC[mode_text[5]]

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

def calculate_total_blocks_and_column_widths(attributes_by_file)
  [
    attributes_by_file.sum(&:blocks),
    attributes_by_file.map(&:nlinks).max.to_s.size,
    attributes_by_file.map { |file_attributes| file_attributes.owner_name.size }.max,
    attributes_by_file.map { |file_attributes| file_attributes.group_name.size }.max,
    attributes_by_file.map(&:size).max.to_s.size
  ]
end

def to_ls_text(file_names)
  file_names = justify_columns(file_names)
  # ファイル数が列数の倍数になるように末尾に空文字追加
  file_names += [''] * (file_names.size.ceildiv(N_COLUMNS) * N_COLUMNS - file_names.size)

  # 上から下、左から右へ昇順、指定した列数になるように表示
  ls_text = ''
  n_rows = file_names.size / N_COLUMNS
  n_rows.times do |row|
    N_COLUMNS.times { |col| ls_text += file_names[row + n_rows * col] }
    ls_text += "\n"
  end
  ls_text.rstrip
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

def to_ls_not_found_text(paths)
  paths.map { |path| "ls: #{path}: No such file or directory" }.join("\n")
end

main if __FILE__ == $PROGRAM_NAME
