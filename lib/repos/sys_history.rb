require 'import'
require 'hits'

require 'karlsquell/repository'

module Repos
  class SysHistory < Karlsquell::Repository[:sys_history]
    commands update: :by_pk

    def total
      sys_history.count
    end

    def with_history_data(page: 1, per_page: 100)
      offset = (page - 1) * per_page
      limit  = per_page

      sys_history
        .with_history_data
        .limit(limit)
        .offset(offset)
        .to_a
    end

    def update_history_data(uid, str)
      update(uid, history_data: str)
    end
  end
end
