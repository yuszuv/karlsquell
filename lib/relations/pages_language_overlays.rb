require 'karlsquell/relation'

module Relations
  class PagesLanguageOverlays < Karlsquell::Relation[:sql]
    schema(:pages_language_overlay, infer: true)

    def by_pid(pid)
      where(pid: pid)
    end
  end
end
