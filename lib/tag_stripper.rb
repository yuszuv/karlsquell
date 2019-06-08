require 'import'

require 'diff'

class TagStripper
  include Import[logger: :diff_logger]

  def call(str)
    str
      .gsub(/\r|\n/, "")
      .then(&method(:remove_karlsquell_spans))
      .then(&method(:remove_karlsquell_ps))
      .then(&method(:remove_comment_spans))
  end

  def matching_tags?(str)
    str &&
      (str[/<span class="karlsquell"/] ||
       str[/<p class="karlsquell"/]  ||
       str[/<span class="comment"/])
  end

  private

  def remove_comment_spans(str)
    remove_tags(str, /(?=<span class="comment")/m, /(?=<\/span)/, /<span.*?<\/span>/)
  end

  def remove_karlsquell_spans(str)
    remove_tags(str, /(?=<span class="karlsquell")/m, /(?=<\/span)/, /<span.*?<\/span>/)
  end

  def remove_karlsquell_ps(str)
    remove_tags(str, /(?=<p class="karlsquell")/m, /(?=<\/p)/, /<p.*?<\/p>/)
  end

  def remove_tags(str, check, splitter, pattern)
    if str =~ check
      without_top_level = str.split(check).map do |split|
        strip_top_level_tag(split, check, splitter, pattern)
      end.join('')
      remove_tags(without_top_level, check, splitter, pattern)
    else
      str
    end
  end

  def strip_top_level_tag(str, check, splitter, pattern)
    if str =~ pattern
      left, right, *rest = str.split(splitter)
      span_end, right    = right[0..6], right[7..-1]

      old_left = [left, span_end].join("")
      new_left = old_left.sub(pattern, '')

      logger.info(Diff.new(left: new_left, right: old_left, format: :html).diff)

      out = [
        new_left,
        right,
        rest.join('')
      ].join('')

      out
    else
      str
    end
  end
end
