#!/usr/bin/env ruby

score = ARGV[0]
socres = score.split(',')
shots = []
socres.each do |s|
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
    point += frames[i+1].sum
    if frames[i+1][0] == 10
      point += frames[i+2][0]
    end
  elsif frame_sum == 10
    point += frames[i+1][0]
  end
  break if i == 9
end
p point
