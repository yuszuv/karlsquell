require 'karlsquell/transaction'
require 'import'

module Transactions
  class DeleteTtContentByFeGroup < Karlsquell::Transaction
    include Import[
      logger: :logger,
      repo: :'repos.tt_content'
    ]

    def call(str)
      logger.info "Deleting tt_content with fe_group = '#{str}'"

      hits = yield delete_by_fe_group(str)

      logger.info("\n%s" % hits.log)

      Success()
    end

    private

    def delete_by_fe_group(str)
      Success(repo.delete_by_fe_group(str))
    rescue # => database error
      Failure("#delete failed")
    end

  end
end
