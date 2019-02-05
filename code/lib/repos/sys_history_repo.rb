require 'lib/client'
require 'lib/struct_parser'
require 'lib/hits'

class SysHistoryRepo

  attr_reader :client
  attr_reader :struct_parser

  def initialize(client, struct_parser = StructParser.new)
    @client        = client
    @struct_parser = struct_parser
  end

  def total
    client.call("SELECT count(*) FROM sys_history;").last.chomp.to_i
  end

  def with_history_data(page = 1, per_page = 100)
    offset, limit = (page - 1) * per_page , per_page
    query         = "SELECT uid, history_data FROM sys_history WHERE history_data IS NOT NULL LIMIT #{offset}, #{limit};"

    struct_parser.call(client.call(query))
  end

  def update_history_data(uid, str)
    query = "UPDATE sys_history SET history_data = '#{sanitize_string(str)}' WHERE uid = '#{uid}';"

    client.call(query)
  end

  def sanitize_string(str)
    str.gsub(/`/,'\\\`').
      gsub(/\r/, '\\r').
      gsub(/'/){ "\\'" }
  end
end
