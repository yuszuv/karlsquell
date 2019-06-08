require 'import'

require 'hits'

require 'karlsquell/repository'

module Repos
  class TtContent < Karlsquell::Repository[:tt_content]
    commands update: :by_pk

    def total
      tt_content.count
    end

    def by_id(id)
      tt_content.by_id(id).one
    end

    def update_bodytext(uid, str)
      update(uid, bodytext: str)
    end

    def karlsquell_pages_with_bodytext(page: 1, per_page: 100)
      offset = (page - 1) * per_page
      limit  = per_page

      tt_content
        .with_bodytext
        .limit(limit)
        .offset(offset)
        .to_a
    end

    def delete_by_page(uid)

      sys_hits  = delete_sys_table_entries(uid)

      tt_content_hits = tt_content
        .with_pid(uid)
        .delete

      Hits.new(
        tt_content: tt_content_hits,
        sys_log: sys_hits.sys_log,
        sys_history: sys_hits.sys_history
      )
    end

    def delete_by_fe_group(str)
      uids = tt_content
        .with_fe_group(str)
        .to_a
        .map(&:uid)

      sys_hits = uids
        .map(&method(:delete_sys_table_entries))
        .reduce(Hits.none, :+)

      cnt = tt_content.with_fe_group(str).delete

      tt_content_hits = Hits.new(tt_content: cnt)

      tt_content_hits + sys_hits
    end

    private

    def delete_sys_table_entries(uid)
      sys_log_hits     = delete_sys_log_entries(uid)
      sys_history_hits = delete_sys_history_entries(uid)

      sys_log_hits + sys_history_hits
    end

    def delete_sys_log_entries(uid)
      ids = sys_log
        .scoped_to_tt_content
        .where(recuid: uid)
        .to_a
        .map{ |h| h[:uid] }

      hits = sys_log.where(uid: ids).delete

      Hits.new(sys_log: hits)
    end

    def delete_sys_history_entries(uid)
      ids = sys_history
        .scoped_to_tt_content
        .where(recuid: uid)
        .to_a
        .map{ |h| h[:uid] }

      hits = sys_history.where(uid: ids).delete

      Hits.new(sys_history: hits)
    end

  end
end
