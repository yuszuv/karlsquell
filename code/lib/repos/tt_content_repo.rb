require 'lib/client'
require 'lib/struct_parser'
require 'lib/tt_content'
require 'lib/hits'

class TtContentRepo

  attr_reader :client
  attr_reader :struct_parser

  def initialize(client, struct_parser = StructParser.new)
    @client = client
    @struct_parser = struct_parser
  end

  def total
    client.call("SELECT count(*) FROM tt_content;").last.chomp.to_i
  end

  def by_id(id)
    query = "SELECT uid, bodytext FROM tt_content WHERE uid = \"#{id}\" LIMIT 1;"

    map_response(client.call(query)).first
  end

  def update_bodytext(uid, str)
    query = "UPDATE tt_content SET bodytext = '#{sanitize_string(str)}' WHERE uid = '#{uid}';"

    client.call(query)
  end
  def karlsquell_pages_with_bodytext(page = 1, per_page = 100)
    offset, limit = (page - 1) * per_page , per_page
    query         = "SELECT uid, bodytext FROM tt_content WHERE bodytext IS NOT NULL LIMIT #{offset}, #{limit};"

    map_response(client.call(query))
  end

  def delete_by_page(page)
    uid   = page.uid
    query = "DELETE FROM tt_content WHERE pid = '#{uid}';
             SELECT row_count() AS count;"

    sys_hits        = delete_sys_table_entries(uid)
    tt_content_hits = struct_parser.call(client.call(query)).first.count.to_i

    Hits.new(0, tt_content_hits, 0, sys_hits.sys_log, sys_hits.sys_history)
  end

  def delete_by_fe_group(str)
    uids_query = "SELECT uid FROM tt_content WHERE fe_group = '#{str}';"

    uids = struct_parser.call(client.call(uids_query))

    sys_hits = uids.map(&:uid).reduce(Hits.none) do |res, uid|
      new_hits = delete_sys_table_entries(uid)

      res + new_hits
    end

    query = "DELETE FROM tt_content WHERE fe_group = '#{str}';
             SELECT row_count() AS count;"

    cnt             = struct_parser.call(client.call(query)).first.count.to_i
    tt_content_hits = Hits.new(0, cnt, 0, 0, 0)

    tt_content_hits + sys_hits
  end

  private

  def delete_sys_table_entries(uid)
    sys_log_hits     = delete_sys_log_entries(uid)
    sys_history_hits = delete_sys_history_entries(uid)

    Hits.new(0, 0, 0, sys_log_hits, sys_history_hits)
  end

  def delete_sys_log_entries(uid)
    query = "DELETE FROM sys_log WHERE tablename ='tt_content' AND recuid ='#{uid}';
             SELECT row_count() AS count;"

    struct_parser.call(client.call(query)).first.count.to_i
  end

  def delete_sys_history_entries(uid)
    query = "DELETE FROM sys_history WHERE tablename ='tt_content' AND recuid ='#{uid}';
             SELECT row_count() AS count;"

    struct_parser.call(client.call(query)).first.count.to_i
  end

  def map_response(tuples)
    struct_parser.call(tuples).
      map(&:marshal_dump).
      map{ |x| TtContent.from_hash(x) }
  end

  def sanitize_string(str)
    str.gsub(/`/,'\\\`').
      gsub(/\r/, '\\r').
      gsub(/'/){ "\\'" }
  end
end
