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

      POSTGIS_NATIVE_DATABASE_TYPES = {
        geometry: { name: "geometry" },
      }.freeze

      NATIVE_DATABASE_TYPES = PostgreSQLAdapter::NATIVE_DATABASE_TYPES.merge(POSTGIS_NATIVE_DATABASE_TYPES)

      include PostGIS::SchemaStatements
      include PostGIS::DatabaseStatements

      class << self
        # PostgreSQLAdapter.native_database_types resolves NATIVE_DATABASE_TYPES
        # lexically, so shadowing the constant in this subclass has no effect.
        def native_database_types # :nodoc:
          @native_database_types ||= super.merge(POSTGIS_NATIVE_DATABASE_TYPES)
        end

        def initialize_type_map(m)
          register_class_with_limit m, "geometry", PostGIS::OID::Geometry
          super
        end

        def extract_limit(sql_type)
          if sql_type =~ /geometry\(([a-zA-Z]*),(\d+)\)/i
            { :type => $1, :srid => $2.to_i }
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
