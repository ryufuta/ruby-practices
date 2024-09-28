# frozen_string_literal: true

require_relative 'shot'
require_relative 'frame'

class Game
  def initialize(marks_text)
    marks_by_frame = parse_marks(marks_text)
    @frames = marks_by_frame.map.with_index { |marks, idx| Frame.new(idx, *marks) }
  end

  def score
    @frames.sum { |frame| frame.score(@frames) }
  end

  private

  def parse_marks(marks_text)
    marks = marks_text.split(',')
    Array.new(9) do
      Shot.new(marks.first).strike? ? marks.shift(1) : marks.shift(2)
    end << marks
  end
end
