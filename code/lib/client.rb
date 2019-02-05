require 'open3'

class Client

  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end

  def call(str)
    logger.debug str
    cmd = <<EOF
db.sh <<- EOL
#{str}
EOL
EOF
    Open3.popen3(cmd) do |stdin, stdout, stderr|
      out = stdout.readlines
      stdout.close

      err = stderr.readlines
      err.each{ |str| logger.error(str) } if err.any?
      stderr.close

      out
    end
  end

end
