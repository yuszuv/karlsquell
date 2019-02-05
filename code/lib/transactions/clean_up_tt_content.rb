require 'lib/diff'

class CleanUpTtContent

  LIMIT    = 1_000_000
  PER_PAGE = 500

  attr_reader :logger
  attr_reader :repo
  attr_reader :stripper

  def initialize(logger, repo, stripper)
    @logger   = logger
    @repo     = repo
    @stripper = stripper
  end

  def call(limit=LIMIT)
    total_pages, per_page = pagination(limit)

    (1..total_pages).each do |page_num|
      records = repo.karlsquell_pages_with_bodytext(page_num, per_page).each do |tt_content|

        result =
          if stripper.matching_tags?(tt_content.bodytext) && ! ["902822", "839496", "848772"].include?(tt_content.uid.to_s)
            logger.info "Updating tt_content with UID: #{tt_content.uid}"
            strip(tt_content) 
          else
            Diff.none
          end

        logger.info(result.log) if result.present?

        true
      end
    end
  end

  private

  def strip(tt_content)
    old_bodytext = tt_content.bodytext
    new_bodytext = stripper.call(old_bodytext)

    repo.update_bodytext(tt_content.uid, new_bodytext)

    Diff.new(new_bodytext, old_bodytext)
  end

  def pagination(limit)
    total_pages = ([repo.total, limit].min.to_f / PER_PAGE).ceil

    [total_pages, PER_PAGE]
  end
end
