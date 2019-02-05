class DeleteTtContentByFeGroup

  attr_reader :logger
  attr_reader :repo

  def initialize(logger, repo)
    @logger = logger
    @repo   = repo
  end

  def call(str)
    logger.info "Deleting tt_content with fe_group = '#{str}'"

    hits = delete(str)

    logger.info(hits.log)
  end

  private

  def delete(str)
    repo.delete_by_fe_group(str)
  end

end
