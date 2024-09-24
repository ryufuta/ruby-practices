# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/shot'

class ShotTest < Minitest::Test
  def test_score_number
    shot = Shot.new('9')
    assert_equal 9, shot.score
  end

  def test_score_strike
    shot = Shot.new('X')
    assert_equal 10, shot.score
  end

  def test_score_nil
    shot = Shot.new(nil)
    assert_equal 0, shot.score
  end

  def test_strike
    shot = Shot.new('X')
    assert shot.strike?
  end

  def test_not_strike
    shot = Shot.new('10')
    refute shot.strike?
  end
end
