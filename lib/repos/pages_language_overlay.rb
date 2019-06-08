require 'import'

require 'karlsquell/repository'

module Repos
  class PagesLanguageOverlay < Karlsquell::Repository[:pages_language_overlay]

    def delete_by_page(uid)
      hits =
        pages_language_overlay
        .by_pid(uid)
        .delete

      Hits.new(pages_language_overlay: hits)
    end

  end
end
