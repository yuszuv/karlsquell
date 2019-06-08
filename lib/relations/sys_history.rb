require 'karlsquell/relation'

module Relations
  class SysHistory < Karlsquell::Relation[:sql]
    schema(:sys_history) do
      attribute :uid, Types::Integer
      attribute :history_data, Types::String
      attribute :recuid, Types::Integer
      attribute :tablename, Types::String

      primary_key :uid
    end

    def with_history_data
      exclude(history_data: nil)
    end

    def scoped_to_pages
      where(tablename: 'pages')
    end

    def scoped_to_tt_content
      where(tablename: 'tt_content')
    end
  end
end
