require 'import'
require 'karlsquell/transaction'

module Transactions
  class DeletePageByFeGroup < Karlsquell::Transaction
    include Dry::Monads::List::Mixin

    include Import[
      logger: :logger,
      error_logger: :error_logger,
      page_repo: :'repos.page',
      do_delete_page_with_subtree: :'transactions.delete_page_with_subtree'
    ]

    def call(str)
      pages = yield fetch_pages(str)

      logger.info "Pages with fe_group = '#{str}': #{pages.count}"

      hits, errors = delete_pages(pages)
      missed_pages = yield fetch_pages(str)

      log = <<~EOF

      pages before: #{pages.size}

      #{hits.log}

      errors:      #{errors.size}
      pages after: #{missed_pages.size}
      EOF

      logger.info(log)

      Success()
    end

    private

    def fetch_pages(str)
      Success(page_repo.by_fe_group(str))
    rescue # database error
      message = "Failed to get pages for fe_group = '#{str}'"

      error_logger.info(message)
      Failure(message)
    end

    def delete_pages(pages)
      results = pages.map(&:uid).map(&method(:delete_page_with_subtree))

      hits = List[*results.map(&:to_maybe)]
        .collect(&:itself)
        .value
        .reduce(Hits.none, :+)

      errors = results.select(&:failure?)

      [hits, errors]
    end

    def delete_page_with_subtree(uid)
      do_delete_page_with_subtree.delete(uid)
    rescue # => Database error
      message = "could not delete page and subtree of uid = '#{uid}'"

      error_logger.info(message)
      Failure(message)
    end
  end
end
