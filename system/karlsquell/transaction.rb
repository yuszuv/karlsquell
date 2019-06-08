require 'dry/monads/result'
require 'dry/monads/do/all'

module Karlsquell
  class Transaction
    include Dry::Monads::Result::Mixin
    include Dry::Monads::Do::All
  end
end
