require 'karlsquell/transaction'
require 'import'

require 'diff'

module Transactions
  class CleanUpTtContent < Karlsquell::Transaction
    include Dry::Monads::List::Mixin
    include Dry::Monads::Maybe::Mixin

    include Import[
      logger: :logger,
      error_logger: :error_logger,
      repo: :'repos.tt_content',
      stripper: :tag_stripper
    ]

    LIMIT    = 1_000_000
    PER_PAGE = 500

    UTF8_FUCKED_UP = %w(
      902822
      839496
      848772
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
      message = 'pagination for tt_content repo could not be read'

      error_logger.info(message)
      Failure(message)
    end

    def update_chunk(page_num)
      list = repo.karlsquell_pages_with_bodytext(page: page_num, per_page: PER_PAGE)

      list.map{ |elem| strip(elem) }
    rescue => e # => database error
      message = "page #{page_num} failed to update"

      error_logger.info(message)
      [Failure(message)]
    end

    def strip(elem)
      if matching_tags?(elem)
        logger.info "Updating tt_content with UID: #{elem.uid}"

        result = yield talk_to_database(elem)

        Success(Some(result))
      else
        Success(None())
      end
    end

    def matching_tags?(elem)
      stripper.matching_tags?(elem.bodytext) &&
        ! UTF8_FUCKED_UP.include?(elem.uid.to_s)
    end

    def talk_to_database(tt_content)
      uid          = tt_content.uid
      old_bodytext = tt_content.bodytext
      new_bodytext = stripper.(old_bodytext)

      begin
        repo.update_bodytext(uid, new_bodytext)

        Success(Diff.new(left: new_bodytext, right: old_bodytext))
      rescue => e # database error
        message = "tt_content with uid #{uid} not updated"

        error_logger.info(message)
        Failure(message)
      end
    end
  end
end
