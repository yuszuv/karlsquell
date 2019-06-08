class Result
  class << self
    def none
      new
    end
  end

  def log
    to_s
  end

end
