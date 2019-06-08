require "app"

App.namespace "persistence" do |persistence|
  persistence.boot(:rom) do
    init do
      use :logger

      require "sequel"
      require "rom"

      Sequel.database_timezone = :utc
      Sequel.application_timezone = :local
      # Sequel::Database.sql_log_level = :debug

      opts = {
        host: 'db',
        user: 'user',
        password: 'password',
        sql_log_level: :debug
      }
      rom_config = ROM::Configuration.new(:sql, 'mysql2://localhost/db', opts)
      rom_config.gateways[:default].use_logger(persistence[:logger])

      persistence.register("config", rom_config)
    end

    start do
      config = persistence["persistence.config"]
      config.auto_registration(persistence.root.join("lib/relations"))

      require 'relations/pages_language_overlays'
      config.register_relation(Relations::PagesLanguageOverlays)

      require 'relations/pages'
      config.register_relation(Relations::Pages)

      require 'relations/sys_history'
      config.register_relation(Relations::SysHistory)
      require 'relations/sys_log'
      config.register_relation(Relations::SysLog)

      require 'relations/tt_content'
      config.register_relation(Relations::TtContent)

      persistence.register("rom", ROM.container(config))
    end

  end
end

