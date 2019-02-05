require 'lib/hits'

class DeletePageWithSubtree

  attr_reader :logger
  attr_reader :page_repo
  attr_reader :tt_content_repo
  attr_reader :pages_language_overlay_repo

  def initialize(logger, page_repo, tt_content_repo, pages_language_overlay_repo)
    @logger                      = logger
    @page_repo                   = page_repo
    @tt_content_repo             = tt_content_repo
    @pages_language_overlay_repo = pages_language_overlay_repo
  end

  def call(uid)
    result = delete(uid)

    logger.info(result.log)

    result
  end

  def delete(uid)
    page     = page_repo.by_id(uid)

    result = if page
      sub_hits = delete_subtree(page)
      hits     = delete_page(page)

      hits + sub_hits
    else
      Hits.none
    end
  end


  private

  def delete_subtree(page)
    page_repo.children_of(page).reduce(Hits.none) do |hits, child|
      sub_hits = delete(child.uid)

      hits + sub_hits
    end
  end

  def delete_page(page)
    hits      = tt_content_repo.delete_by_page(page)
    plo_hits  = pages_language_overlay_repo.delete_by_page(page)
    page_hits = page_repo.delete(page.uid)

    hits + plo_hits + page_hits
  end

end
