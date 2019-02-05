class TtContent < Struct.new(:uid, :bodytext)

  class << self

    def from_hash(hash)
      uid = hash[:uid]
      bodytext = hash[:bodytext] == "NULL" ? nil : hash[:bodytext]

      new(uid, bodytext)
    end

  end

  def with_bodytext(str)
    self.class.new(uid, str)
  end

end
