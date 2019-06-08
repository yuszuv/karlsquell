require "byebug" if ENV["RACK_ENV"] == "development"
require "pry" if ENV["RACK_ENV"] == "development"

require 'dry/system/container'

class App < Dry::System::Container
  configure do |config|
    config.auto_register = %w[lib/repos lib/transactions]
  end

  load_paths! "lib", "system"
end

App.start(:logger)

require 'tag_stripper'
App.register :tag_stripper, TagStripper.new

App.finalize!
