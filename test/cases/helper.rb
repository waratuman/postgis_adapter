require "active_record"
require "postgis_adapter"

require "active_support"
require "active_support/testing/autorun"

ActiveRecord::Base.logger = ActiveSupport::Logger.new("debug.log", 0, 100 * 1024 * 1024)

ActiveRecord::Base.configurations = ActiveRecord::DatabaseConfigurations.new({
  postgis_test: {
      adapter: "postgis",
      database: "postgis_adapter_test",
      min_messages: "warning"
  }
})
ActiveRecord::Base.establish_connection :postgis_test

require_relative "./models"
