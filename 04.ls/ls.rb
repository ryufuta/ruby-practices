#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_WIDTH_UNIT = 8
N_COLUMNS = 3

def main
  file_names = Dir.glob('*')

  return if file_names.empty?

  file_names = justify_columns(file_names)
  puts to_ls_text(file_names)
end

def justify_columns(file_names)
  # 全角文字は2文字分カウント
  max_name_length = file_names.map { |file_name| file_name.size + count_full_width_chars(file_name) }.max

  column_width = min_multiple(max_name_length + 1, COLUMN_WIDTH_UNIT)

  # 全角文字は2文字分の幅のためその分短くする
  file_names.map { |file_name| file_name.ljust(column_width - count_full_width_chars(file_name)) }
end

def count_full_width_chars(str)
  str.scan(/[^\x01-\x7E\uFF65-\uFF9F]/).size
end

def to_ls_text(file_names)
  # ファイル数が列数の倍数になるように末尾に空文字追加
  file_names += [''] * (min_multiple(file_names.size, N_COLUMNS) - file_names.size)

  # 上から下、左から右へ昇順、指定した列数になるように表示
  ls_text = ''
  n_rows = file_names.size / N_COLUMNS
  n_rows.times do |row|
    N_COLUMNS.times { |col| ls_text += file_names[row + n_rows * col] }
    ls_text += "\n"
  end
  ls_text
end

def min_multiple(number, divisor)
  residue = number % divisor
  residue.zero? ? number : number + divisor - residue
end

main if __FILE__ == $PROGRAM_NAME
