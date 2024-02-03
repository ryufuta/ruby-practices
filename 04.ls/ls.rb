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
  ARGV.empty? ? ls_without_args(options) : ls_with_args(options, ARGV)
end

def ls_without_args(options)
  file_names = options['a'] ? Dir.entries('.').sort : Dir.glob('*')
  file_names = file_names.reverse if options['r']
  if options['l']
    puts to_ls_l_text(file_names)
  else
    ls_text = to_ls_text(file_names)
    puts ls_text unless ls_text.empty?
  end
end

def ls_with_args(options, args)
  file_paths_not_found, file_paths, file_names_by_dir = to_sorted_paths(options, args)
  if options['l']
    puts to_ls_l_args_text(file_paths_not_found, file_paths, file_names_by_dir)
  else
    ls_args_text = to_ls_args_text(file_paths_not_found, file_paths, file_names_by_dir)
    puts ls_args_text unless ls_args_text.empty?
  end
end

def to_ls_l_args_text(file_paths_not_found, file_paths, file_names_by_dir)
  ls_not_found_text = to_ls_not_found_text(file_paths_not_found)
  ls_l_files_text_with_lf = file_paths.empty? ? '' : "#{to_ls_l_text(file_paths, total_blocks_required: false)}\n\n"
  ls_l_dirs_text = to_ls_l_dirs_text(file_names_by_dir, ls_not_found_text.empty? && ls_l_files_text_with_lf.empty?)
  "#{ls_not_found_text}\n#{ls_l_files_text_with_lf}#{ls_l_dirs_text}".strip
end

def to_ls_l_dirs_text(file_names_by_dir, dirs_only)
  return '' if file_names_by_dir.empty?

  return to_ls_l_text(file_names_by_dir[0][1], file_names_by_dir[0][0]) if dirs_only && file_names_by_dir.size == 1

  file_names_by_dir.map { |dir_path, file_names| "#{dir_path}:\n#{to_ls_l_text(file_names, dir_path)}" }.join("\n\n")
end

def to_ls_l_text(file_names, base_dir = nil, total_blocks_required: true)
  return 'total 0' if file_names.empty?

  xattr_found = system('which xattr', out: '/dev/null', err: '/dev/null')
  attributes_by_file = file_names.map { |file_name| fetch_file_attributes(file_name, xattr_found, base_dir) }
  total_blocks, max_digit_links, max_owner_name_length, max_group_name_length, max_digit_file_size =
    calculate_total_blocks_and_column_widths(attributes_by_file)
  total_blocks_text_with_ls = total_blocks_required ? "total #{total_blocks}\n" : ''
  total_blocks_text_with_ls + attributes_by_file.map do |file_attributes|
    "#{file_attributes.file_type_with_permissions}#{file_attributes.xattr || ' '} "\
    "#{file_attributes.nlinks.to_s.rjust(max_digit_links)} "\
    "#{file_attributes.owner_name.ljust(max_owner_name_length)}  "\
    "#{file_attributes.group_name.ljust(max_group_name_length)}  "\
    "#{file_attributes.size.to_s.rjust(max_digit_file_size)} "\
    "#{file_attributes.updated_at} "\
    "#{file_attributes.file_name}"
  end.join("\n")
end

def fetch_file_attributes(file_name, xattr_found, base_dir = nil)
  file_path = base_dir.nil? ? file_name : File.join(base_dir, file_name)
  file_attributes = File.lstat(file_path)
  FileAttribute.new(
    file_attributes.blocks,
    to_symbolic_notation(file_attributes.mode),
    xattr_found && !Open3.capture3("xattr -s #{file_path}")[0].empty? ? '@' : nil,
    file_attributes.nlink,
    Etc.getpwuid(file_attributes.uid).name,
    Etc.getgrgid(file_attributes.gid).name,
    file_attributes.size,
    format_timestamp(file_attributes.mtime),
    file_attributes.symlink? ? "#{file_name} -> #{File.readlink(file_path)}" : file_name
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
  return '' if file_names.empty?

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

def to_sorted_paths(options, args)
  file_paths_not_found, file_paths, dir_paths = group_paths_by_type(args, options['l'])
  # 同じディレクトリが複数回指定されたときは重複して表示するためハッシュではなく配列を使う
  file_names_by_dir = dir_paths.map do |dir_path|
    file_names = Dir.entries(dir_path).sort
    file_names = file_names.reject { |file_name| file_name[0] == '.' } unless options['a']
    file_names = file_names.reverse if options['r']
    [dir_path, file_names]
  end

  if options['r']
    file_paths = file_paths.reverse
    file_names_by_dir = file_names_by_dir.reverse
  end
  [file_paths_not_found, file_paths, file_names_by_dir]
end

def group_paths_by_type(paths, l_option)
  file_paths_not_found = []
  file_paths = []
  dir_paths = []
  paths.each do |path|
    next file_paths_not_found << path unless File.exist?(path)

    next file_paths << path if !File.directory?(path) || (l_option && File.symlink?(path))

    dir_paths << path
  end
  [file_paths_not_found.sort, file_paths.sort, dir_paths.sort]
end

def to_ls_args_text(file_paths_not_found, file_paths, file_names_by_dir)
  ls_not_found_text = to_ls_not_found_text(file_paths_not_found)
  ls_files_text = to_ls_text(file_paths)
  ls_dirs_text = to_ls_dirs_text(file_names_by_dir, ls_not_found_text.empty? && ls_files_text.empty?)
  ls_files_text_with_lf = ls_files_text.empty? ? '' : "#{ls_files_text}\n\n"
  "#{ls_not_found_text}\n#{ls_files_text_with_lf}#{ls_dirs_text}".strip
end

def to_ls_dirs_text(file_names_by_dir, dirs_only)
  return '' if file_names_by_dir.empty?

  return to_ls_text(file_names_by_dir[0][1]) if dirs_only && file_names_by_dir.size == 1

  file_names_by_dir.map do |dir_path, file_names|
    ls_text_with_lf = file_names.empty? ? '' : "\n#{to_ls_text(file_names)}"
    "#{dir_path}:#{ls_text_with_lf}"
  end.join("\n\n")
end

def to_ls_not_found_text(paths)
  paths.map { |path| "ls: #{path}: No such file or directory" }.join("\n")
end

main if __FILE__ == $PROGRAM_NAME
