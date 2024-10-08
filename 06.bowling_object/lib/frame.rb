# frozen_string_literal: true

require_relative 'shot'

class Frame
  def initialize(idx, shots)
    @idx = idx
    @shots = shots
  end

  def score(frames)
    score_without_bonus + bonus_score(frames)
  end

  protected

  def strike?
    @shots.size == 1
  end

  def shot_scores
    @shots.map(&:score)
  end

  private

  def score_without_bonus
    shot_scores.sum
  end

  def bonus_score(frames)
    return 0 if final?

    next_frame = frames[@idx + 1]
    if strike?
      second_next_shot_score = next_frame.strike? ? frames[@idx + 2].shot_scores[0] : next_frame.shot_scores[1]
      next_frame.shot_scores[0] + second_next_shot_score
    elsif spare?
      next_frame.shot_scores[0]
    else
      0
    end
  end

  def final?
    @idx == 9
  end

  def spare?
    !strike? && score_without_bonus == 10
  end
end
