# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/base_directory'

class BaseDirectoryTest < Minitest::Test
  DIR_PATH = 'test/fixtures/sample-app'
  EMPTY_DIR_PATH = 'test/fixtures/empty_dir'

  def test_file_names
    expected = %w[Gemfile Gemfile.lock README.md app.rb dbinit.sh public views]
    assert_equal expected, BaseDirectory.new(DIR_PATH).file_names
  end

  def test_file_names_empty
    assert_equal [], BaseDirectory.new(EMPTY_DIR_PATH).file_names
  end

  def test_max_file_name_length
    expected = 'Gemfile.lock'.length # 12
    assert_equal expected, BaseDirectory.new(DIR_PATH).max_file_name_length
  end
end
