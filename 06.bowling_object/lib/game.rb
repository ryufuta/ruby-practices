# frozen_string_literal: true

require_relative 'shot'
require_relative 'frame'

class Game
  def initialize(marks_text)
    shots_by_frame = parse_marks(marks_text)
    @frames = shots_by_frame.map.with_index { |shots, idx| Frame.new(idx, shots) }
  end

  def score
    @frames.sum { |frame| frame.score(@frames) }
  end

  private

  def parse_marks(marks_text)
    marks = marks_text.split(',')
    shots = marks.map { |mark| Shot.new(mark) }
    Array.new(10) do |idx|
      if idx == 9
        shots
      else
        shots.first.strike? ? shots.shift(1) : shots.shift(2)
      end
    end
  end
end
