require 'karlsquell/transaction'
require 'import'

module Transactions
  class DeletePagesLanguageOverlayByFeGroup < Karlsquell::Transaction
    include Import[
      logger: :logger,
      error_logger: :error_logger,
      repo: :'repos.page'
    ]

    def call(str)
      logger.info "Deleting pages_language_overlay with fe_group = '#{str}'"

      hits = yield delete(str)

      logger.info("\n%s" % hits.log)

      Success()
    end

    private

    def delete(str)
      Success(repo.delete_by_fe_group(str))
    rescue # => TODO: database error
      Failure("#delete failed")
    end
  end
end
