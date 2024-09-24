# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/frame'

class FrameTest < Minitest::Test
  def test_score_no_bonus
    frames = []
    10.times do |idx|
      frames << (idx == 9 ? Frame.new(idx, 'X', 'X', '1') : Frame.new(idx, '1', '5'))
    end

    frame_with_two_shots = frames.first
    assert_equal 6, frame_with_two_shots.score(frames)

    frame_with_three_shots = frames.last
    assert_equal 21, frame_with_three_shots.score(frames)
  end

  def test_score_spare
    frames = []
    10.times do |idx|
      frames << (idx.zero? ? Frame.new(idx, '1', '9') : Frame.new(idx, '1', '5'))
    end

    assert_equal 11, frames.first.score(frames)
  end

  def test_score_single_strike
    frames = []
    10.times do |idx|
      frames << (idx.zero? ? Frame.new(idx, 'X') : Frame.new(idx, '1', '5'))
    end

    assert_equal 16, frames.first.score(frames)
  end

  def test_score_double_strike
    frames = []
    10.times do |idx|
      frames << (idx < 2 ? Frame.new(idx, 'X') : Frame.new(idx, '1', '5'))
    end

    assert_equal 21, frames.first.score(frames)
  end

  # def test_strike
  #   frame = Frame.new('X')
  #   assert frame.strike?
  # end

  # def test_not_strike
  #   frame = Frame.new('0', '10')
  #   refute frame.strike?
  # end

  # def test_spare
  #   frame = Frame.new('1', '9')
  #   assert frame.spare?
  # end

  # def test_not_spare
  #   frame = Frame.new('1', '1')
  #   refute frame.spare?

  #   strike_frame = Frame.new('X')
  #   refute strike_frame.spare?
  # end

  # def test_score_first_shot
  #   frame = Frame.new('1', '9')
  #   assert_equal 1, frame.score_first_shot
  # end

  # def test_score_second_shot
  #   frame = Frame.new('1', '9')
  #   assert_equal 9, frame.score_second_shot
  # end

  # def test_only_one_shot
  #   frame = Frame.new('X')
  #   assert frame.only_one_shot?
  # end

  # def test_not_only_one_shot
  #   frame = Frame.new('1', '9')
  #   refute frame.only_one_shot?

  #   frame_with_three_shots = Frame.new('X', '1', '9')
  #   refute frame_with_three_shots.only_one_shot?
  # end
end
