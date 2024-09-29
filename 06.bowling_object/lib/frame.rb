# frozen_string_literal: true

require_relative 'shot'

class Frame
  def initialize(idx, first_mark, second_mark = nil, third_mark = nil)
    @idx = idx
    @shots = [Shot.new(first_mark), Shot.new(second_mark), Shot.new(third_mark)]
  end

  def score(frames)
    score_without_bonus + bonus_score(frames)
  end

  private

  def score_without_bonus
    @shots.sum(&:score)
  end

  def bonus_score(frames)
    return 0 if final?

    next_frame = frames[@idx + 1]
    if strike?
      next_frame.shot_scores[0] +
        if next_frame.strike? && !next_frame.final?
          frames[@idx + 2].shot_scores[0]
        else
          next_frame.shot_scores[1]
        end
    elsif spare?
      next_frame.shot_scores[0]
    else
      0
    end
  end

  def spare?
    !strike? && score_without_bonus == 10
  end

  protected

  def final?
    @idx == 9
  end

  def strike?
    @shots.first.strike?
  end

  def shot_scores
    @shots.map(&:score)
  end
end
