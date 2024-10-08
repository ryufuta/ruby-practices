# frozen_string_literal: true

require_relative 'ls_file'

class BaseDirectory
  def initialize(path, dot_match: false, reverse: false)
    @path = path
    file_names = collect_file_names(path, dot_match, reverse)
    @files = file_names.map { |file_name| LsFile.new(path, file_name) }.freeze
  end

  def file_names
    @files.map(&:name)
  end

  def max_file_name_length
    file_names.map(&:size).max
  end

  def file_attributes
    @file_attributes ||= @files.map(&:attribute)
  end

  def total_blocks
    file_attributes.sum(&:blocks)
  end

  def max_sizes
    [
      file_attributes.map(&:nlinks).max.to_s.size,
      file_attributes.map { |file_attribute| file_attribute.user_name.size }.max,
      file_attributes.map { |file_attribute| file_attribute.group_name.size }.max,
      file_attributes.map(&:size).max.to_s.size
    ]
  end

  private

  def collect_file_names(path, dot_match, reverse)
    file_names_with_dot = Dir.entries(path).sort
    file_names = dot_match ? file_names_with_dot : file_names_with_dot.reject { |file_name| file_name[0] == '.' }
    reverse ? file_names.reverse : file_names
  end
end
