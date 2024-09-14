# frozen_string_literal: true

require_relative 'shot'

class Frame
  def initialize(first_mark, second_mark = nil, third_mark = nil)
    @first_shot = Shot.new(first_mark)
    @second_shot = Shot.new(second_mark)
    @third_shot = Shot.new(third_mark)
  end

  def score
    [@first_shot.score, @second_shot.score, @third_shot.score].sum
  end

  def strike?
    @first_shot.mark == 'X'
  end

  def spare?
    @first_shot.mark != 'X' && score == 10
  end

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
