# frozen_string_literal: true

require_relative 'shot'

class Frame
  def initialize(idx, first_mark, second_mark = nil, third_mark = nil)
    @idx = idx
    @shots = [Shot.new(first_mark), Shot.new(second_mark), Shot.new(third_mark)]
  end

  def score(frames)
    final? ? score_without_bonus : score_without_bonus + score_bonus(frames)
  end

  private

  def score_without_bonus
    @shots.sum(&:score)
  end

  def final?
    @idx == 9
  end

  def score_bonus(frames)
    next_frame = frames[@idx + 1]
    if strike?
      next_frame.score_first_shot + (next_frame.only_one_shot? ? frames[@idx + 2].score_first_shot : next_frame.score_second_shot)
    elsif spare?
      next_frame.score_first_shot
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

  def score_first_shot
    @shots.first.score
  end

  def score_second_shot
    @shots[1].score
  end

  def only_one_shot?
    @shots[1].mark.nil?
  end
end
