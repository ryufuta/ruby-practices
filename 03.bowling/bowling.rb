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
frames.each do |frame|
  if frame[0] == 10
    point += 30
  elsif frame.sum == 10
    point += frame[0] + 10
  else
    point += frame.sum
  end
end
p point
