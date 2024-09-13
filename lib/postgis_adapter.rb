require 'active_record/connection_adapters'
require 'postgis_adapter/railtie' if defined?(Rails)

ActiveRecord::ConnectionAdapters.register("postgis", "ActiveRecord::ConnectionAdapters::PostGISAdapter", "active_record/connection_adapters/postgis_adapter")
