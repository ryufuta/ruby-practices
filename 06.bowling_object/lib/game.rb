# frozen_string_literal: true

require_relative 'shot'
require_relative 'frame'

class Game
  def initialize(marks_text)
    @frames = parse_marks(marks_text)
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
        Frame.new(idx, shots)
      else
        shots_in_a_frame = shots.first.strike? ? shots.shift(1) : shots.shift(2)
        Frame.new(idx, shots_in_a_frame)
      end
    end
  end
end
