# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/frame'
require_relative '../lib/shot'

class FrameTest < Minitest::Test
  def test_score_no_bonus
    frames = Array.new(10) do |idx|
      if idx == 9
        Frame.new(idx, [Shot.new('X'), Shot.new('X'), Shot.new('1')])
      else
        Frame.new(idx, [Shot.new('1'), Shot.new('5')])
      end
    end

    frame_with_two_shots = frames.first
    assert_equal 6, frame_with_two_shots.score(frames)

    frame_with_three_shots = frames.last
    assert_equal 21, frame_with_three_shots.score(frames)
  end

  def test_score_spare
    frames = Array.new(10) do |idx|
      idx.zero? ? Frame.new(idx, [Shot.new('1'), Shot.new('9')]) : Frame.new(idx, [Shot.new('1'), Shot.new('5')])
    end

    assert_equal 11, frames.first.score(frames)
  end

  def test_score_single_strike
    frames = Array.new(10) do |idx|
      idx.zero? ? Frame.new(idx, [Shot.new('X')]) : Frame.new(idx, [Shot.new('1'), Shot.new('5')])
    end

    assert_equal 16, frames.first.score(frames)
  end

  def test_score_double_strike
    frames = Array.new(10) do |idx|
      idx < 2 ? Frame.new(idx, [Shot.new('X')]) : Frame.new(idx, [Shot.new('1'), Shot.new('5')])
    end

    assert_equal 21, frames.first.score(frames)
  end

  def test_score_double_strike_at_final_two_frames
    frames = Array.new(10) do |idx|
      if idx == 8
        Frame.new(idx, [Shot.new('X')])
      elsif idx == 9
        Frame.new(idx, [Shot.new('X'), Shot.new('1'), Shot.new('5')])
      else
        Frame.new(idx, [Shot.new('1'), Shot.new('5')])
      end
    end

    assert_equal 21, frames[8].score(frames)
  end
end
