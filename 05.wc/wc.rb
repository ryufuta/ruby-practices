#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_WIDTH = 8

def main
  file_path = ARGV[0]
  counts = []
  File.open(file_path, 'r') do |f|
    lines = f.readlines
    counts << lines.count
    counts << lines.sum { |line| line.split(/\s+/).count }
  end
  counts << File.size(file_path)
  puts "#{counts.map { |count| count.to_s.rjust(COLUMN_WIDTH) }.join} #{file_path}"
end

main if __FILE__ == $PROGRAM_NAME
