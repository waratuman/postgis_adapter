module ActiveRecord
  module ConnectionAdapters
    module PostGIS
      module SchemaStatements
        include PostgreSQL::SchemaStatements

        def type_to_sql(sql_type, limit: nil, precision: nil, scale: nil, array: nil, type: 'Geometry', srid: 4326, **) # :nodoc:
          case sql_type.to_s
          when 'geometry'
            "geometry(#{type},#{srid})"
          else
            super
          end
        end

        private

        def create_table_definition(*args)
          PostGIS::TableDefinition.new(self, *args)
        end

      end
    end
  end
end
