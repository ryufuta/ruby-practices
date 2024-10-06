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

  def test_run_dot_match
    expected = <<~TEXT.chomp
      .               .rubocop.yml    app.rb
      ..              Gemfile         dbinit.sh
      .erb-lint.yml   Gemfile.lock    public
      .gitignore      README.md       views
    TEXT
    assert_equal expected, LsCommand.new(DIR_PATH, dot_match: true).run
  end

  def test_run_reverse
    expected = <<~TEXT.chomp
      views           app.rb          Gemfile
      public          README.md
      dbinit.sh       Gemfile.lock
    TEXT
    assert_equal expected, LsCommand.new(DIR_PATH, reverse: true).run
  end
end
