#!/usr/bin/env ruby
# frozen_string_literal: true

# カレントディレクトリのファイルエントリ取得
file_names = Dir.glob('*')

# 列幅調整
file_names = file_names.map { |file_name| file_name.ljust(16) }

# ファイル数が３の倍数になるように末尾に空文字追加
file_names += [''] * (3 - file_names.size % 3) unless (file_names.size % 3) == 0

# 上から下、左から右へ昇順、3列になるように表示
ls_text = ''
n_rows = file_names.size / 3
n_rows.times do |row|
  ls_text += "#{file_names[row]}#{file_names[row + n_rows]}#{file_names[row + n_rows * 2]}\n"
end

puts ls_text
