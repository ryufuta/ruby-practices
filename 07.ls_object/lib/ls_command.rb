# frozen_string_literal: true

require_relative 'base_directory'
require_relative 'long_formatter'
require_relative 'short_formatter'

class LsCommand
  def initialize(path, dot_match: false, long_format: false, reverse: false)
    @base_directory = BaseDirectory.new(path, dot_match:, reverse:)
    @formatter = long_format ? LongFormatter.new : ShortFormatter.new
  end

  def run
    @formatter.format(@base_directory)
  end
end
