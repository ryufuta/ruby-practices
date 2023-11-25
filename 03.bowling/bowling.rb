#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = []
shots.each_slice(2) do |s|
  frames << s
end

point = 0
frames.each.with_index do |frame, i|
  frame_sum = frame.sum
  point += frame_sum
  if frame[0] == 10
    point += frames[i + 1].sum
    point += frames[i + 2][0] if frames[i + 1][0] == 10
  elsif frame_sum == 10
    point += frames[i + 1][0]
  end
  break if i == 9
end
puts point
