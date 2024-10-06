# frozen_string_literal: true

require_relative 'short_formatter'

class LsCommand
  def initialize(path, dot_match: false)
    @file_names = collect_file_names(path, dot_match).freeze
    @formatter = ShortFormatter.new
  end

  def run
    @formatter.format(@file_names)
  end

  private

  def collect_file_names(path, dot_match)
    file_names = Dir.entries(path).sort
    dot_match ? file_names : file_names.reject { |file_name| file_name[0] == '.' }
  end
end
