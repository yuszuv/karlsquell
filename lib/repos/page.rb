require 'ostruct'

require 'karlsquell/repository'

require 'hits'

module Repos
  class Page < Karlsquell::Repository[:pages]

    def by_id(uid)
      pages.with_id(uid).one
    end

    def count_by_fe_group(str)
      pages.with_fe_group(str).count
    end

    def by_fe_group(str)
      pages.with_fe_group(str).to_a
    end

    def children_of(uid)
      pages.children_of(uid).to_a
    end

    def delete(uid)
      sys_hits = delete_sys_table_entries(uid)

      hits = pages.with_id(uid).delete

      Hits.new(
        page: hits,
        sys_log: sys_hits.sys_log,
        sys_history: sys_hits.sys_history
      )
    end

    private

    def delete_sys_table_entries(uid)
      sys_log_hits     = delete_sys_log_entries(uid)
      sys_history_hits = delete_sys_history_entries(uid)

      sys_log_hits + sys_history_hits
    end

    def delete_sys_log_entries(uid)
      ids = sys_log
        .scoped_to_pages
        .where(recuid: uid)
        .to_a
        .map{ |h| h[:uid] }

      hits = sys_log.where(uid: ids).delete

      Hits.new(sys_log: hits)
    end

    def delete_sys_history_entries(uid)
      ids = sys_history
        .scoped_to_pages
        .where(recuid: uid)
        .to_a
        .map{ |h| h[:uid] }

      hits = sys_history.where(uid: ids).delete

      Hits.new(sys_history: hits)
    end
  end
end
