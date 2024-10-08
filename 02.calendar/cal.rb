#!/usr/bin/env ruby

require "date"
require "optparse"

FIRST_DAY = 1
CALENDAR_WIDTH = 20
CALENDAR_LINES = 9
SATURDAY = 6

# 指定した年月のカレンダー
def show_calendar(year, month)
  last_day = Date.new(year, month, -1).day
  first_day_of_week = Date.new(year, month, FIRST_DAY).wday

  puts "#{month}月 #{year}".center(CALENDAR_WIDTH)
  puts "日 月 火 水 木 金 土"

  print " " * 3 * first_day_of_week
  day_of_week = first_day_of_week
  n_lines = 3
  today = Date.today
  (FIRST_DAY..last_day).each do |day|
    print_day(day, year, month, today)
    if day_of_week == SATURDAY
      print "\n"
      day_of_week = 0
      n_lines += 1
    else
      print " "
      day_of_week += 1
    end
  end

  print "\n" * (CALENDAR_LINES - n_lines)
end

def print_day(day, year, month, today)
  if year == today.year && month == today.mon && day == today.day
    print "\e[30m\e[47m#{day}\e[0m".rjust(2)
  else
    print "#{day}".rjust(2)
  end
end

def validate_params(params)
  year = params["y"]
  month = params["m"]
  if year.nil?
    year = Date.today.year
  else
    year = year.to_i
    if !year.between?(1, 9999)
      puts "year `#{params["y"]}' not in range 1..9999"
      exit 1
    end
  end
  
  if month.nil?
    month = Date.today.mon
  else
    month = month.to_i
    if !month.between?(1, 12)
      puts "month `#{params["m"]}' not in range 1..12"
      exit 1
    end
  end

  params["y"] = year
  params["m"] = month
  return params
end

params = ARGV.getopts("y:m:")
params = validate_params params
year = params["y"]
month = params["m"]

show_calendar(year, month)
