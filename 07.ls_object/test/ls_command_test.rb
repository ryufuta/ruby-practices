# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/ls_command'

class LsCommandTest < Minitest::Test
  DIR_PATH = 'test/fixtures/sample-app'
  EMPTY_DIR_PATH = 'test/fixtures/empty_dir'

  def test_run
    expected = <<~TEXT.chomp
      Gemfile         app.rb          views
      Gemfile.lock    dbinit.sh
      README.md       public
    TEXT
    assert_equal expected, LsCommand.new(DIR_PATH).run
  end

  def test_run_empty_dir
    assert_equal '', LsCommand.new(EMPTY_DIR_PATH).run
  end
end
