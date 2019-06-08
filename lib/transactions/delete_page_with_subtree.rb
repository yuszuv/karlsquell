require 'karlsquell/transaction'
require 'import'

require 'hits'

module Transactions
  class DeletePageWithSubtree < Karlsquell::Transaction
    include Import[
      logger: :logger,
      error_logger: :error_logger,
      page_repo: :'repos.page',
      tt_content_repo: :'repos.tt_content',
      pages_language_overlay_repo: :'repos.pages_language_overlay'
    ]

    def call(uid)
      result = yield delete(uid)

      logger.info("\n%s" % result.log)

      Success()
    end

    def delete(uid)
      page     = yield fetch_page(uid)

      sub_hits = yield delete_subtree(page)
      hits     = yield delete_page(page)

      Success(hits + sub_hits)
    end

    def fetch_page(uid)
      page = page_repo.by_id(uid)

      if page
        Success(page)
      else
        message = "Could not fetch page with uid = '#{uid}'"
        error_logger.info(message)

        Failure(message)
      end
    end

    private

    def delete_subtree(page)
      hits = page_repo
        .children_of(page.uid)
        .reduce(Hits.none){ |hits, child| hits + (yield delete(child.uid)) }

      Success(hits)
    rescue => e # database error
      Failure("#delete_subtree failed")
    end

    def delete_page(page)
      hits = tt_content_repo.delete_by_page(page.uid) +
        pages_language_overlay_repo.delete_by_page(page.uid) +
        page_repo.delete(page.uid)

      Success(hits)
    rescue => e # database error
      Failure("#delete_page failed")
    end
  end
end
