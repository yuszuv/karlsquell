require 'differ'

require 'result'

class Diff < Result
  attr_reader :diff

  def initialize(left: '', right: '', format: :color)
    @diff = Differ.diff_by_char(left, right).format_as(format)
  end

  def to_s
    diff.to_s
  end

  def inspect
    "#<%s:%s @diff=\"%s\">" % [
      self.class.name,
      object_id,
      truncate(diff.to_s)
    ]
  end

  private

  def truncate(str)
    truncate_at = 100
    omission =  '...'

    return dup unless str.length > truncate_at

    stop = truncate_at - omission.length

    "#{str[0, stop]}#{omission}"
  end

end
