# frozen_string_literal: true

class LsFile
  attr_reader :name

  def initialize(parent_path, name)
    @parent_path = parent_path
    @name = name
  end
end
