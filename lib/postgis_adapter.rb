require 'postgis_adapter/railtie' if defined?(Rails)

if ActiveRecord::ConnectionAdapters.respond_to?(:register)
  ActiveRecord::ConnectionAdapters.register("postgis", "ActiveRecord::ConnectionAdapters::PostGISAdapter", "active_record/connection_adapters/postgis_adapter")
end
