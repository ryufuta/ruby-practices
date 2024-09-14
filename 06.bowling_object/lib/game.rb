# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(marks_text)
    marks_by_frame = self.class.parse_marks(marks_text)
    @frames = marks_by_frame.map { |marks| Frame.new(*marks) }
  end

  def score
    @frames.each_with_index.sum do |frame, i|
      final_frame?(i) ? frame.score : score_non_final(i)
    end
  end

  def final_frame?(idx)
    idx == 9
  end

  def score_non_final(idx)
    frame = @frames[idx]
    frame.score + score_bonus_shots(idx)
  end

  def score_bonus_shots(idx)
    frame = @frames[idx]
    next_frame = @frames[idx + 1]
    if frame.strike?
      next_frame.first_shot.score + (next_frame.second_shot.mark.nil? ? @frames[idx + 2].first_shot.score : next_frame.second_shot.score)
    elsif spare?(frame)
      next_frame.first_shot.score
    else
      0
    end
  end

  def spare?(frame)
    frame.first_shot.mark != 'X' && frame.score == 10
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
