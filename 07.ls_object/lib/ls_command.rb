# frozen_string_literal: true

require_relative 'short_formatter'

class LsCommand
  def initialize(path)
    @file_names = collect_file_names(path).freeze
    @formatter = ShortFormatter.new
  end

  def run
    @formatter.format(@file_names)
  end

  private

  def collect_file_names(path)
    file_names = Dir.entries(path).sort
    file_names.reject { |file_name| file_name[0] == '.' }
  end
end
