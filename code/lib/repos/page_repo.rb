require 'lib/struct_parser'
require 'lib/hits'

class PageRepo

  attr_reader :client
  attr_reader :struct_parser

  def initialize(client, struct_parser = StructParser.new)
    @client = client
    @struct_parser = struct_parser
  end

  def total
  end

  def by_id(uid)
    query = "SELECT #{attributes} FROM pages WHERE uid = '#{uid}';"

    struct_parser.call(client.call(query)).first
  end

  def count_by_fe_group(str)
    query = "SELECT count(*) AS count FROM pages WHERE fe_group = '#{str}';"

    struct_parser.call(client.call(query)).first.count
  end

  def by_fe_group(str)
    query = "SELECT #{attributes} FROM pages WHERE fe_group = '#{str}';"

    struct_parser.call(client.call(query))
  end

  def children_of(page)
    query = "SELECT #{attributes} FROM pages WHERE pid = '#{page.uid}';"

    struct_parser.call(client.call(query))
  end

  def delete(uid)
    query = "DELETE FROM pages WHERE uid = '#{uid}';
             SELECT row_count() AS count;"

    sys_hits = delete_sys_table_entries(uid)
    hits     = struct_parser.call(client.call(query)).first.count.to_i

    Hits.new(hits, 0, 0, sys_hits.sys_log, sys_hits.sys_history)
  end

  private

  def delete_sys_table_entries(uid)
    sys_log_hits     = delete_sys_log_entries(uid)
    sys_history_hits = delete_sys_history_entries(uid)

    sys_log_hits + sys_history_hits
  end

  def delete_sys_log_entries(uid)
    query = "DELETE FROM sys_log WHERE tablename ='pages' AND recuid ='#{uid}';
             SELECT row_count() AS count;"

    Hits.new(0, 0, 0, struct_parser.call(client.call(query)).first.count.to_i, 0)
  end

  def delete_sys_history_entries(uid)
    query = "DELETE FROM sys_history WHERE tablename ='pages' AND recuid ='#{uid}';
             SELECT row_count() AS count;"

    Hits.new(0, 0, 0, 0, struct_parser.call(client.call(query)).first.count.to_i)
  end

  def attributes
    "uid, pid"
  end

end
