require 'dry/initializer'

require 'result'

class Hits < Result
  extend Dry::Initializer

  option :page, default: proc { 0 }
  option :tt_content, default: proc { 0 }
  option :pages_language_overlay, default: proc { 0 }
  option :sys_log, default: proc { 0 }
  option :sys_history, default: proc { 0 }

  def +(other)
    self.class.new(
      page: page + other.page,
      tt_content: tt_content + other.tt_content,
      pages_language_overlay: pages_language_overlay + other.pages_language_overlay,
      sys_log: sys_log + other.sys_log,
      sys_history: sys_history + other.sys_history
    )
  end

  def log
    data = {
      "pages" => page,
      "tt_content" => tt_content,
      "pages_language_overlay" => pages_language_overlay,
      "sys_log" => sys_log,
      "sys_history" => sys_history
    }

    columns = [
      { :label => "table name", :width => 30 },
      { :label => "records deleted", :width => 20 }
    ]

    ([
      divider(columns),
      header(columns),
      divider(columns)
    ] + data.map{ |desc, count| row(desc, count, columns) } + [
      divider(columns)
    ]).join("\n")
  end

  private

  def header(columns)
    "| %s |" % columns.map{ |h| h[:label].ljust(h[:width]) }.join(" | ")
  end

  def divider(columns)
    "+-%s-+" % columns.map{ |h| "-" * h[:width] }.join("-+-")
  end

  def row(desc, count, columns)
    "| %s | %s |" % [desc.ljust(columns[0][:width]), count.to_s.ljust(columns[1][:width])]
  end
end
