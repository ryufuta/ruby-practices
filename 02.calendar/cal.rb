require "date"
require "optparse"

First_day = 1
Calendar_width = 20
Calendar_lines = 9
Saturday = 6

# 指定した年月のカレンダー
def show_calendar(year, month)
  last_day = Date.new(year, month, -1).day
  first_day_of_week = Date.new(year, month, First_day).wday

  puts "#{month}月 #{year}".center(Calendar_width)
  puts "日 月 火 水 木 金 土"

  print " " * 3 * first_day_of_week
  day_of_week = first_day_of_week
  n_lines = 3
  today = Date.today
  (First_day..last_day).each do |day|
    print_day(day, year, month, today)
    if day_of_week == Saturday
      print "\n"
      day_of_week = 0
      n_lines += 1
    else
      print " "
      day_of_week += 1
    end
  end

  print "\n" * (Calendar_lines - n_lines)
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
  end
  
  if month.nil?
    month = Date.today.mon
  else
    month = month.to_i
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
