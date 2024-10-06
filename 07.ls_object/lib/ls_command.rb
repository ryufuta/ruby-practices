# frozen_string_literal: true

require_relative 'short_formatter'

class LsCommand
  def initialize(path, dot_match: false, reverse: false)
    @file_names = collect_file_names(path, dot_match, reverse).freeze
    @formatter = ShortFormatter.new
  end

  def run
    @formatter.format(@file_names)
  end

  private

  def collect_file_names(path, dot_match, reverse)
    file_names_with_dot = Dir.entries(path).sort
    file_names = dot_match ? file_names_with_dot : file_names_with_dot.reject { |file_name| file_name[0] == '.' }
    reverse ? file_names.reverse : file_names
  end
end
