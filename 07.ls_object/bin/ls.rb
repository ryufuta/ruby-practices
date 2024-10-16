#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require_relative '../lib/ls_command'

opt = OptionParser.new

params = { dot_match: false, long_format: false, reverse: false }
opt.on('-a') { |v| params[:dot_match] = v }
opt.on('-l') { |v| params[:long_format] = v }
opt.on('-r') { |v| params[:reverse] = v }
opt.parse!(ARGV)
path = ARGV[0] || '.'

puts LsCommand.new(path, **params).run
