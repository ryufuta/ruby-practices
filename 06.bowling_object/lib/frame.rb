# frozen_string_literal: true

require_relative 'shot'

class Frame
  def initialize(idx, first_mark, second_mark = nil, third_mark = nil)
    @idx = idx
    @first_shot = Shot.new(first_mark)
    @second_shot = Shot.new(second_mark)
    @third_shot = Shot.new(third_mark)
  end

  def score(frames)
    final? ? score_without_bonus : score_without_bonus + score_bonus(frames)
  end

  private

  def score_without_bonus
    [@first_shot.score, @second_shot.score, @third_shot.score].sum
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
    @first_shot.mark == 'X'
  end

  def spare?
    @first_shot.mark != 'X' && score_without_bonus == 10
  end

  protected

  def score_first_shot
    @first_shot.score
  end

  def score_second_shot
    @second_shot.score
  end

  def only_one_shot?
    @second_shot.mark.nil?
  end
end
