require 'karlsquell/relation'

module Relations
  class Pages < Karlsquell::Relation[:sql]
    schema(:pages) do
      attribute :uid, Types::Integer
      attribute :pid, Types::Integer

      primary_key :uid

      associations do
        has_many :sys_history, foreign_key: :recuid, view: :scoped_to_pages
        has_many :sys_log, foreign_key: :recuid, view: :scoped_to_pages
      end
    end

    def with_id(id)
      where(uid: id)
    end

    def with_fe_group(str)
      where(fe_group: str)
    end

    def children_of(uid)
      where(pid: uid)
    end

  end
end
