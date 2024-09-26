# frozen_string_literal: true

require_relative 'shot'

class Frame
  def initialize(idx, first_mark, second_mark = nil, third_mark = nil)
    @idx = idx
    @shots = [Shot.new(first_mark), Shot.new(second_mark), Shot.new(third_mark)]
  end

  def score(frames)
    final? ? score_without_bonus : score_without_bonus + bonus_score(frames)
  end

  private

  def score_without_bonus
    @shots.sum(&:score)
  end

  def final?
    @idx == 9
  end

  def bonus_score(frames)
    next_frame = frames[@idx + 1]
    if strike?
      next_frame.shot_scores[0] + (next_frame.only_one_shot? ? frames[@idx + 2].shot_scores[0] : next_frame.shot_scores[1])
    elsif spare?
      next_frame.shot_scores[0]
    else
      0
    end
  end

  def strike?
    @shots.first.strike?
  end

  def spare?
    !strike? && score_without_bonus == 10
  end

  protected

  def shot_scores
    @shots.map(&:score)
  end

  def only_one_shot?
    @shots[1].mark.nil?
  end
end
