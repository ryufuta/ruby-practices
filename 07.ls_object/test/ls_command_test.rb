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

  def test_run_long_format
    # Output example
    # total 40
    # -rw-r--r--  1 ryufuta  staff   232 Oct  4 18:14 Gemfile
    # -rw-r--r--  1 ryufuta  staff  3098 Oct  4 18:14 Gemfile.lock
    # -rw-r--r--  1 ryufuta  staff   429 Dec 10  2023 README.md
    # -rw-r--r--  1 ryufuta  staff  1787 Oct  4 18:14 app.rb
    # -rwxr-xr-x  1 ryufuta  staff   279 Oct  4 18:14 dbinit.sh
    # drwxr-xr-x  3 ryufuta  staff    96 Oct  4 18:14 public
    # drwxr-xr-x  8 ryufuta  staff   256 Oct  4 18:14 views
    expected = `ls -l #{DIR_PATH}`.chomp
    assert_equal expected, LsCommand.new(DIR_PATH, long_format: true).run
  end

  def test_run_long_format_empty_dir
    assert_equal 'total 0', LsCommand.new(EMPTY_DIR_PATH, long_format: true).run
  end

  def test_run_all_options
    expected = `ls -alr #{DIR_PATH}`.chomp
    assert_equal expected, LsCommand.new(DIR_PATH, dot_match: true, long_format: true, reverse: true).run
  end
end
