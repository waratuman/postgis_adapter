require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'
require 'active_record/connection_adapters/postgis/version'
require 'active_record/connection_adapters/postgis/oid/geometry'
require 'active_record/connection_adapters/postgis/schema_definitions'
require 'active_record/connection_adapters/postgis/schema_statements'
require 'active_record/connection_adapters/postgis/database_statements'

ActiveRecord::SchemaDumper.ignore_tables |= %w[geometry_columns spatial_ref_sys layer topology]
module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter < PostgreSQLAdapter
      ADAPTER_NAME = 'PostGIS'.freeze

      NATIVE_DATABASE_TYPES = PostgreSQLAdapter::NATIVE_DATABASE_TYPES.merge!({
        geometry: { name: "geometry" },
      })

      include PostGIS::SchemaStatements
      include PostGIS::DatabaseStatements

      class << self
        def initialize_type_map(m)
          register_class_with_limit m, "geometry", PostGIS::OID::Geometry
          super
        end

        def extract_limit(sql_type)
          if sql_type =~ /geometry\(([a-zA-Z]*),(\d+)\)/i
            { :type => $1, :srid => $2 }
          else
            super
          end
        end
      end

      ActiveRecord::Type.send(:registry).send(:registrations).select do |registration|
        registration.send(:matches_adapter?, adapter: :postgresql)
      end.each do |registration|
        r = registration.dup
        r.instance_variable_set(:@adapter, :postgis)
        ActiveRecord::Type.send(:registry).send(:registrations) << r
      end

    end
  end
end
