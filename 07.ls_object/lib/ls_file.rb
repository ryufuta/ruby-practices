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

  Attribute = Data.define(:type_and_mode, :nlinks, :user_name, :group_name, :size, :mtime, :file_name, :blocks)

  attr_reader :name

  def initialize(parent_path, name)
    @parent_path = parent_path
    @name = name
  end

  def attribute
    stat = File.lstat(path)
    Attribute.new(
      type_and_mode_text(stat.mode),
      stat.nlink,
      Etc.getpwuid(stat.uid).name,
      Etc.getgrgid(stat.gid).name,
      stat.size,
      stat.mtime,
      @name,
      stat.blocks
    )
  end

  private

  def path
    File.join(@parent_path, @name)
  end

  def type_and_mode_text(mode)
    mode_text = mode.to_s(8).rjust(6, '0')
    type = TYPE_TABLE[mode_text[0, 2]]
    user_permission = MODE_TABLE[mode_text[3]]
    group_permission = MODE_TABLE[mode_text[4]]
    other_permission = MODE_TABLE[mode_text[5]]

    "#{type}#{user_permission}#{group_permission}#{other_permission}"
  end
end
