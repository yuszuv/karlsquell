class DeletePageByFeGroup

  attr_reader :logger
  attr_reader :page_repo
  attr_reader :delete_page_with_subtree

  def initialize(logger, page_repo, delete_page_with_subtree)
    @logger                   = logger
    @page_repo                = page_repo
    @delete_page_with_subtree = delete_page_with_subtree
  end

  def call(str)
    pages = page_repo.by_fe_group(str)

    logger.info "Pages with fe_group = '#{str}': #{pages.count}"

    result = pages.reduce(Hits.none) do |hits, page|
      page_hits = delete_page_with_subtree.delete(page.uid)

      hits + page_hits
    end

    missed_pages = page_repo.by_fe_group(str)

    logger.info(result.log)
    logger.info "Pages with fe_group = '#{str}': #{missed_pages.count}"

    result
  end

  # FIXME
  def database_data(str)
    Hash[
      ["pages", "tt_content"].map do |name|
        count = struct_parser.call(client.call("SELECT count(*) AS count FROM #{name} WHERE fe_group ='#{str}'")).first.count

        [name, count]
      end
    ]
  end

  # private

  # def delete_with_subtree(page)
  #   sub_hits = delete_subtree(page)
  #   hits     = delete(page)

  #   hits + sub_hits
  # end

  # def delete_subtree(page)
  #   page_repo.children_of(page).reduce(Hits.new( 0, 0, 0, 0, 0 )) do |hits, child|
  #     child_hits = delete_with_subtree(child)

  #     hits + child_hits
  #   end
  # end

  # def delete(page)
  #   tt_content_hits = tt_content_repo.delete_by_page(page)
  #   plo_hits        = pages_language_overlay_repo.delete_by_page(page)
  #   page_hits       = page_repo.delete(page.uid)

  #   page_hits + tt_content_hits + plo_hits
  # end

end
