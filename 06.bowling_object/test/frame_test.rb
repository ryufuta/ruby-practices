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

  def test_score_double_strike_at_final_two_frames
    frames = []
    10.times do |idx|
      frames << if idx == 8
                  Frame.new(idx, 'X')
                elsif idx == 9
                  Frame.new(idx, 'X', '1', '5')
                else
                  Frame.new(idx, '1', '5')
                end
    end

    assert_equal 21, frames[8].score(frames)
  end
end
