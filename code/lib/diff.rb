require 'rubygems'
gem 'differ'

require 'differ'

class Diff

  class << self

    def none
      new("", "")
    end

  end

  attr_reader :diff

  def initialize(left, right, format = :color)
    @diff = Differ.diff_by_char(left, right).format_as(format)
  end

  def present?
    diff.to_s != ""
  end

  def to_s
    diff.to_s
  end
  alias log to_s

  def inspect
    diff.inspect
  end

end
