#!/usr/bin/env ruby
# frozen_string_literal: true

def main
  # カレントディレクトリのファイルエントリ取得
  file_names = Dir.glob('*')

  file_names = justify_columns(file_names)
  puts to_ls_text(file_names)
end

def justify_columns(file_names, column_width = 16)
  # 指定した半角文字数の列幅にする。全角文字は2文字分の幅のためその分短くする
  file_names.map do |file_name|
    # 全角文字をいくつ含むか
    n_full_widths = file_name.scan(/[^\x01-\x7E\uFF65-\uFF9F]/).size
    file_name.ljust(column_width - n_full_widths)
  end
end

def to_ls_text(file_names, n_columns = 3)
  # ファイル数が列数の倍数になるように末尾に空文字追加
  file_names += [''] * (n_columns - file_names.size % n_columns) unless (file_names.size % n_columns) == 0

  # 上から下、左から右へ昇順、指定した列数になるように表示
  ls_text = ''
  n_rows = file_names.size / n_columns
  n_rows.times do |row|
    n_columns.times { |col| ls_text += file_names[row + n_rows * col] }
    ls_text += "\n"
  end
  ls_text
end

main if __FILE__ == $PROGRAM_NAME
