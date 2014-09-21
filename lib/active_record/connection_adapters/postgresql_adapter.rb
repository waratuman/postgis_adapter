require 'active_record/connection_adapters/postgresql_adapter'

require_relative './postgresql/oid/geometry'
require_relative './postgresql/column_methods'
require_relative './postgresql/table_definition'

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter

      NATIVE_DATABASE_TYPES.merge!({
        geometry: {name: 'geometry'},
      })

      # TODO: Extract method to MLS
      # PostgreSQL Array quoting; This should be moved to MLS, has nothing to do
      # with this extension, but support for contains and overlaps nodes in Arel
      def quote_array(value)
        type = PostgreSQL::OID::Array.new("ActiveRecord::Type::#{value[0].class}".constantize.new)
        type.type_cast_for_database(value)
      end

      def initialize_type_map_with_postgis(m)
        register_class_with_limit m, 'geometry', OID::Geometry
        initialize_type_map_without_postgis(m)
      end
      alias_method_chain :initialize_type_map, :postgis

      def extract_limit_with_postgis(sql_type)
        if sql_type =~ /geometry\(([a-zA-Z]*),(\d+)\)/i
          { :type => $1, :srid => $2 }
        else
          extract_limit_without_postgis(sql_type)
        end
      end
      alias_method_chain :extract_limit, :postgis

      def type_to_sql_with_postgis(type, limit = nil, precision = nil, scale = nil)
        case type.to_s
        when 'geometry'
          limit ? "geometry(#{limit[:type]},#{limit[:srid]})" : 'geometry'
        else
          type_to_sql_without_postgis(type, limit, precision, scale)
        end
      end
      alias_method_chain :type_to_sql, :postgis

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

    end

  end
end

