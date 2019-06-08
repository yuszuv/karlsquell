require 'karlsquell/relation'

module Relations
  class SysLog < Karlsquell::Relation[:sql]
    schema(:sys_log) do
      attribute :uid, Types::Integer
      attribute :recuid, Types::Integer
      attribute :tablename, Types::String

      primary_key :uid
    end

    def scoped_to_pages
      where(tablename: 'pages')
    end

    def scoped_to_tt_content
      where(tablename: 'tt_content')
    end
  end
end
