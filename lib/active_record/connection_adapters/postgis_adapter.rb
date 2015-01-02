require 'active_record/connection_adapters/postgresql_adapter'
require 'active_record/connection_adapters/postgis/oid/geometry'
require 'active_record/connection_adapters/postgis/schema_definitions'
require 'active_record/connection_adapters/postgis/attribute'

ActiveRecord::SchemaDumper.ignore_tables |= %w[geometry_columns spatial_ref_sys layer topology]
module ActiveRecord

  class SchemaDumper

    # TODO: Extract extension schema, ci to Rails core (See other todo for other methods to related to this)
    def extensions(stream)
      return unless @connection.supports_extensions?
      extensions = @connection.extensions
      if extensions.any?
        stream.puts "  # These are extensions that must be enabled in order to support this database"
        extensions.each do |extension|
          line = "  enable_extension #{extension[:name].inspect}"
          line << ", schema: #{extension[:schema].inspect}" if extension[:schema] && extension[:schema] != 'public'
          stream.puts line
        end
        stream.puts
      end
    end

  end

  module ConnectionHandling # :nodoc:

    # Establishes a connection to the database that's used by all Active Record objects
    def postgis_connection(config)
      conn_params = config.symbolize_keys

      conn_params.delete_if { |_, v| v.nil? }

      # Map ActiveRecords param names to PGs.
      conn_params[:user] = conn_params.delete(:username) if conn_params[:username]
      conn_params[:dbname] = conn_params.delete(:database) if conn_params[:database]

      # Forward only valid config params to PGconn.connect.
      conn_params.keep_if { |k, _| VALID_CONN_PARAMS.include?(k) }

      # The postgres drivers don't allow the creation of an unconnected PGconn object,
      # so just pass a nil connection object for the time being.
      ConnectionAdapters::PostGISAdapter.new(nil, logger, conn_params, config)
    end

  end

  module ConnectionAdapters
    class PostGISAdapter < PostgreSQLAdapter

      NATIVE_DATABASE_TYPES = PostgreSQLAdapter::NATIVE_DATABASE_TYPES.merge!({
        geometry: {name: 'geometry'},
      })

      # TODO: Extract method to MLS
      # PostgreSQL Array quoting; This should be moved to MLS, has nothing to do
      # with this extension, but support for contains and overlaps nodes in Arel
      def quote_array(value)
        type = PostgreSQL::OID::Array.new("ActiveRecord::Type::#{value[0].class}".constantize.new)
        type.type_cast_for_database(value)
      end

      def initialize_type_map(m)
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

      def type_to_sql(type, limit = nil, precision = nil, scale = nil)
        case type.to_s
        when 'geometry'
          limit ? "geometry(#{limit[:type]},#{limit[:srid]})" : 'geometry'
        else
          super
        end
      end

      # TODO: Extract extension schema, ci to Rails core (See other todo for other methods to related to this)
      def enable_extension(name, opts={})
        query = "CREATE EXTENSION IF NOT EXISTS \"#{name}\""
        if opts[:schema]
          exec_query("CREATE SCHEMA IF NOT EXISTS \"#{opts[:schema]}\"")
          query << " SCHEMA \"#{opts[:schema]}\"" 
        end
        exec_query(query).tap {
          reload_type_map
        }
      end

      # TODO: Extract extension schema, ci to Rails core (See other todo for other methods to related to this)
      def extensions
        if supports_extensions?
          extensions = exec_query("SELECT extname, nspname FROM pg_extension INNER JOIN pg_namespace ON pg_extension.extnamespace = pg_namespace.oid WHERE nspname != 'pg_catalog'", "SCHEMA").cast_values
          extensions.map { |x| { name: x[0], schema: x[1]} }
        else
          super
        end
      end

      private
      
      def create_table_definition(name, temporary, options, as = nil) # :nodoc:
        PostGIS::TableDefinition.new native_database_types, name, temporary, options, as
      end

    end

  end

end

