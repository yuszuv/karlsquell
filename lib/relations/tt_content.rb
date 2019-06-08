require 'karlsquell/relation'

module Relations
  class TtContent < Karlsquell::Relation[:sql]
    schema(:tt_content) do
      attribute :uid, Types::Integer
      attribute :bodytext, Types::String

      primary_key :uid

      associations do
        has_many :sys_history, foreign_key: :recuid, view: :scoped_to_tt_content
        has_many :sys_log, foreign_key: :recuid, view: :scoped_to_tt_content
      end
    end

    def by_id(id)
      where(uid: id)
    end

    def with_pid(pid)
      where(pid: pid)
    end

    def with_bodytext
      exclude(bodytext: nil)
    end

    def with_fe_group(str)
      where(fe_group: str)
    end
  end
end
