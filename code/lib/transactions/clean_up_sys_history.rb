require 'lib/diff'

class CleanUpSysHistory

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
      records = repo.with_history_data(page_num, per_page).each do |sys_hist|

        result =
          if stripper.matching_tags?(sys_hist.history_data) && ! ["972511", "951597", "949273", "949274", "949270", "951598", "949269", "968516", "968518", "972507", "972506", "968517", "951599", "949271"].include?(sys_hist.uid.to_s)
            logger.debug "Updating sys_history with UID: #{sys_hist.uid}"
            strip(sys_hist) 
          else
            Diff.none
          end

        logger.debug(result.log) if result.present?

        true
      end
    end
  end

  private

  def strip(sys_history)
    uid              = sys_history.uid
    old_history_data = sys_history.history_data
    new_history_data = stripper.call(old_history_data)

    repo.update_history_data(uid, new_history_data)

    Diff.new(new_history_data, old_history_data)
  end

  def pagination(limit)
    total_pages = ([repo.total, limit].min.to_f / PER_PAGE).ceil

    [total_pages, PER_PAGE]
  end
end
