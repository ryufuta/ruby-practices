#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMN_WIDTH = 8

def main
  options = ARGV.getopts('lwc')
  use_counts = parse_options(options)
  file_paths = ARGV
  counts_by_row =
    if file_paths.empty?
      lines = $stdin.readlines
      [[nil, count_lines_words_bytes(lines, **use_counts)]]
    else
      counts_by_file = file_paths.map { |file_path| [file_path, count_lines_words_bytes(file_path, **use_counts)] }
      counts_by_file.size > 1 ? [*counts_by_file, ['total', sum_counts(counts_by_file)]] : counts_by_file
    end
  puts to_wc_text(counts_by_row)
end

def parse_options(options)
  if !options['l'] && !options['w'] && !options['c']
    { use_line: true, use_word: true, use_byte: true }
  else
    { use_line: options['l'], use_word: options['w'], use_byte: options['c'] }
  end
end

def count_lines_words_bytes(file_path_or_lines, use_line: true, use_word: true, use_byte: true)
  lines =
    if file_path_or_lines.instance_of?(String)
      File.open(file_path_or_lines, 'r', &:readlines)
    else
      file_path_or_lines
    end

  counts = []
  counts << lines.count if use_line
  counts << lines.sum { |line| line.split(/\s+/).count } if use_word
  counts << lines.sum(&:bytesize) if use_byte
  counts
end

def sum_counts(counts_by_file)
  total_counts = [0] * counts_by_file[0][1].size
  counts_by_file.each do |_, counts|
    counts.each_with_index { |count, i| total_counts[i] += count }
  end
  total_counts
end

def to_wc_text(counts_by_row)
  counts_by_row.map do |row_name, counts|
    "#{counts.map { |count| count.to_s.rjust(COLUMN_WIDTH) }.join} #{row_name}".rstrip
  end.join("\n")
end

main if __FILE__ == $PROGRAM_NAME
