require "date"
require "optparse"

First_day = 1
Calendar_width = 20
Calendar_lines = 9
Saturday = 6

# 今月のカレンダー
def show_this_month_calendar
  today = Date.today
  this_year = today.year
  this_month = today.mon
  last_day = Date.new(this_year, this_month, -1).day
  first_day_of_week = Date.new(this_year, this_month, First_day).wday

  puts "#{this_month}月 #{this_year}".center(Calendar_width)
  puts "日 月 火 水 木 金 土"

  print " " * 3 * first_day_of_week
  day_of_week = first_day_of_week
  n_lines = 3
  (First_day..last_day).each do |day|
    print "#{day}".rjust(2)
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

# 指定した年月のカレンダー
def show_calendar(year, month)
  last_day = Date.new(year, month, -1).day
  first_day_of_week = Date.new(year, month, First_day).wday

  puts "#{month}月 #{year}".center(Calendar_width)
  puts "日 月 火 水 木 金 土"

  print " " * 3 * first_day_of_week
  day_of_week = first_day_of_week
  n_lines = 3
  (First_day..last_day).each do |day|
    print "#{day}".rjust(2)
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

params = ARGV.getopts("y:m:")
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

show_calendar(year, month)
