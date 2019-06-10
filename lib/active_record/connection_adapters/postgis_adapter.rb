require 'active_record/connection_adapters/postgresql_adapter'
require 'active_record/connection_adapters/postgis/oid/geometry'
require 'active_record/connection_adapters/postgis/schema_definitions'
require 'active_record/connection_adapters/postgis/attribute'

ActiveRecord::SchemaDumper.ignore_tables |= %w[geometry_columns spatial_ref_sys layer topology]
module ActiveRecord
  module ConnectionHandling # :nodoc:

    # Establishes a connection to the database that's used by all Active Record objects
    def postgis_connection(config)
      conn_params = config.symbolize_keys

      conn_params.delete_if { |_, v| v.nil? }

      # Map ActiveRecords param names to PGs.
      conn_params[:user] = conn_params.delete(:username) if conn_params[:username]
      conn_params[:dbname] = conn_params.delete(:database) if conn_params[:database]

      # Forward only valid config params to PG::Connection.connect.
      valid_conn_param_keys = PG::Connection.conndefaults_hash.keys + [:requiressl]
      conn_params.slice!(*valid_conn_param_keys)

      conn = PG.connect(conn_params)
      ConnectionAdapters::PostgreSQLAdapter.new(conn, logger, conn_params, config)
    rescue ::PG::Error => error
      if error.message.include?("does not exist")
        raise ActiveRecord::NoDatabaseError
      else
        raise
      end
    end

  end

  module ConnectionAdapters
    class PostGISAdapter < PostgreSQLAdapter
      ADAPTER_NAME = 'PostGIS'.freeze

      NATIVE_DATABASE_TYPES = PostgreSQLAdapter::NATIVE_DATABASE_TYPES.merge!({
        geometry: { name: "geometry" },
      })

      # # TODO: Extract method to MLS
      # # PostgreSQL Array quoting; This should be moved to MLS, has nothing to do
      # # with this extension, but support for contains and overlaps nodes in Arel
      # def quote_array(value)
      #   type = if !value[0]
      #     PostgreSQL::OID::Array.new(nil)
      #   else
      #     PostgreSQL::OID::Array.new("ActiveRecord::Type::#{value[0].class}".constantize.new)
      #   end
      #   type.type_cast_for_database(value)
      # end

      def initialize_type_map(m = type_map)
        register_class_with_limit m, 'geometry', PostGIS::OID::Geometry
        super
      end

      def extract_limit(sql_type)
        if sql_type =~ /geometry\(([a-zA-Z]*),(\d+)\)/i
          { :type => $1, :srid => $2 }
        else
          super
        end
      end

      def type_to_sql(sql_type, type: 'Geometry', srid: 4326, **)
        case sql_type.to_s
        when 'geometry'
          "geometry(#{type},#{srid})"
        else
          super
        end
      end

      private

      def create_table_definition(*args) # :nodoc:
        PostGIS::TableDefinition.new(*args)
      end

    end
  end
end
