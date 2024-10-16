# frozen_string_literal: true

require 'etc'

class LsFile
  TYPE_TABLE = {
    '04' => 'd',
    '10' => '-'
  }.freeze
  MODE_TABLE = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }.freeze

  attr_reader :name, :type_and_mode, :nlinks, :user_name, :group_name, :size, :mtime, :blocks

  def initialize(parent_path, name)
    @parent_path = parent_path
    @name = name

    stat = File.lstat(path)
    @type_and_mode = type_and_mode_text(stat.mode)
    @nlinks = stat.nlink
    @user_name = Etc.getpwuid(stat.uid).name
    @group_name = Etc.getgrgid(stat.gid).name
    @size = stat.size
    @mtime = stat.mtime
    @blocks = stat.blocks
  end

  private

  def path
    File.join(@parent_path, @name)
  end

  def type_and_mode_text(mode)
    mode_text = mode.to_s(8).rjust(6, '0')
    type = TYPE_TABLE[mode_text[0, 2]]
    permissions = mode_text[3, 5].gsub(/./, MODE_TABLE)
    "#{type}#{permissions}"
  end
end
