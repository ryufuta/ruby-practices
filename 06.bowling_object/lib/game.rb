# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(marks_text)
    marks_by_frame = self.class.parse_marks(marks_text)
    @frames = marks_by_frame.map.with_index { |marks, idx| Frame.new(idx, *marks) }
  end

  def score
    @frames.sum { |frame| frame.score(@frames) }
  end

  def self.parse_marks(marks_text)
    marks = marks_text.split(',')
    marks_by_frame = []
    9.times do
      marks_by_frame << if marks.first == 'X'
                          marks.shift(1)
                        else
                          marks.shift(2)
                        end
    end
    marks_by_frame << marks
  end
end
