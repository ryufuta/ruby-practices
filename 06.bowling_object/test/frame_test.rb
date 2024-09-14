# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/frame'

class FrameTest < Minitest::Test
  def test_score_strike
    frame = Frame.new('X')
    assert_equal 10, frame.score
  end

  def test_score_two_shots
    frame = Frame.new('0', '10')
    assert_equal 10, frame.score
  end

  def test_score_three_shots
    frame = Frame.new('X', 'X', '1')
    assert_equal 21, frame.score
  end

  def test_strike
    frame = Frame.new('X')
    assert frame.strike?
  end

  def test_not_strike
    frame = Frame.new('0', '10')
    refute frame.strike?
  end

  def test_spare
    frame = Frame.new('1', '9')
    assert frame.spare?
  end

  def test_not_spare
    frame = Frame.new('1', '1')
    refute frame.spare?

    strike_frame = Frame.new('X')
    refute strike_frame.spare?
  end

  def test_score_first_shot
    frame = Frame.new('1', '9')
    assert_equal 1, frame.score_first_shot
  end

  def test_score_second_shot
    frame = Frame.new('1', '9')
    assert_equal 9, frame.score_second_shot
  end

  def test_only_one_shot
    frame = Frame.new('X')
    assert frame.only_one_shot?
  end

  def test_not_only_one_shot
    frame = Frame.new('1', '9')
    refute frame.only_one_shot?

    frame_with_three_shots = Frame.new('X', '1', '9')
    refute frame_with_three_shots.only_one_shot?
  end
end
