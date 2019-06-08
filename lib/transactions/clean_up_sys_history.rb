require 'karlsquell/transaction'
require 'import'

require 'diff'

module Transactions
  class CleanUpSysHistory < Karlsquell::Transaction
    include Dry::Monads::List::Mixin
    include Dry::Monads::Maybe::Mixin

    include Import[
      logger: :logger,
      error_logger: :error_logger,
      repo: :'repos.sys_history',
      stripper: :tag_stripper
    ]

    LIMIT    = 1_000_000
    PER_PAGE = 500

    UTF8_FUCKED_UP = %w(
      972511
      951597
      949273
      949274
      949270
      951598
      949269
      968516
      968518
      972507
      972506
      968517
      951599
      949271
    )

    def call(limit=LIMIT)
      total_pages, per_page = yield pagination(limit)

      results, errors = (1..total_pages).map do |page_num|
        update_chunk(page_num)
      end
        .flatten
        .partition(&:success?)

      diffs = List[*results.map(&:value!)].collect(&:itself)

      log = <<~EOF

        untouched: #{results.size - diffs.size}
        updated:   #{diffs.size}
        errors:    #{errors.size}
      EOF

      logger.info(log)

      Success()
    end

    private

    def pagination(limit)
      total_pages = ([repo.total, limit].min.to_f / PER_PAGE).ceil

      Success([total_pages, PER_PAGE])
    rescue # database error
      message = 'pagination for sys_history repo could not be read'

      error_logger.info(message)
      Failure(message)
    end


    def update_chunk(page_num)
      list = repo.with_history_data(page: page_num, per_page: PER_PAGE)

      list.map{ |elem| strip(elem) }
    rescue => e # => database error
      message = "page #{page_num} failed to update"

      error_logger.info(message)
      [Failure(message)]
    end

    def strip(elem)
      if matching_tags?(elem)
        logger.info "Updating sys_history with UID: #{elem.uid}"

        result = yield talk_to_database(elem)

        Success(Some(result))
      else
        Success(None())
      end
    end

    def matching_tags?(elem)
      stripper.matching_tags?(elem.history_data) &&
        ! UTF8_FUCKED_UP.include?(elem.uid.to_s)
    end

    def talk_to_database(sys_history)
      uid              = sys_history.uid
      old_history_data = sys_history.history_data
      new_history_data = stripper.(old_history_data)

      begin
        repo.update_history_data(uid, new_history_data)

        Success(Diff.new(left: new_history_data, right: old_history_data))
      rescue => e # database error
        message = "sys_history with uid #{uid} not updated"

        error_logger.info(message)
        Failure(message)
      end
    end
  end
end
