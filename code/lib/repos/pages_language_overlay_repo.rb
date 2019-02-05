require 'lib/hits'

class PagesLanguageOverlayRepo

  attr_reader :client
  attr_reader :struct_parser

  def initialize(client, struct_parser = StructParser.new)
    @client = client
    @struct_parser = struct_parser
  end

  def delete_by_page(page)
    query =
      "DELETE FROM pages_language_overlay WHERE pid ='#{page.uid}';
       SELECT row_count() AS count;"

    hits = struct_parser.call(client.call(query)).first.count.to_i

    Hits.new(0, 0, hits, 0, 0)
  end

end
