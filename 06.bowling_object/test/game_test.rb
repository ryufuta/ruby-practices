# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/game'

class GameTest < Minitest::Test
  def test_score_no_bonus
    game = Game.new('1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5')
    assert_equal 60, game.score
  end

  def test_score_no_strike
    game = Game.new('1,9,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,9,1')
    assert_equal 70, game.score
  end

  # 提出用と同じテストケース
  def test_score1
    game = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,6,4,5')
    assert_equal 139, game.score
  end

  def test_score2
    game = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,X,X')
    assert_equal 164, game.score
  end

  def test_score3
    game = Game.new('0,10,1,5,0,0,0,0,X,X,X,5,1,8,1,0,4')
    assert_equal 107, game.score
  end

  def test_score4
    game = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,0,0')
    assert_equal 134, game.score
  end

  def test_score5
    game = Game.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,1,8')
    assert_equal 144, game.score
  end

  def test_score6_perfect
    game = Game.new('X,X,X,X,X,X,X,X,X,X,X,X')
    assert_equal 300, game.score
  end

  def test_score7
    game = Game.new('X,X,X,X,X,X,X,X,X,X,X,2')
    assert_equal 292, game.score
  end

  def test_score8
    game = Game.new('X,0,0,X,0,0,X,0,0,X,0,0,X,0,0')
    assert_equal 50, game.score
  end
end
