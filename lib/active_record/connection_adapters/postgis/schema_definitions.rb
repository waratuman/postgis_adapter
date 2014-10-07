module ActiveRecord
  module ConnectionAdapters
    module PostGIS

      module ColumnMethods
        include PostgreSQL::ColumnMethods

        def geometry(name, options = {})
          column(name, :geometry, options)
        end

      end

      class ColumnDefinition < ActiveRecord::ConnectionAdapters::PostgreSQL::ColumnDefinition
      end

      class TableDefinition < ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition
        include PostGIS::ColumnMethods

        private

        def create_column_definition(name, type)
          PostGIS::ColumnDefinition.new name, type
        end
      end

    end
  end
end