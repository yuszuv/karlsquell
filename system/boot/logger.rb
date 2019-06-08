require 'app'

App.boot(:logger) do
  init do
    require 'logger'
  end

  start do
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO

    register(:logger, logger)
    register(:error_logger, Logger.new('log/errors.log'))
    register(:diff_logger, Logger.new('log/diff.log'))
  end
end
