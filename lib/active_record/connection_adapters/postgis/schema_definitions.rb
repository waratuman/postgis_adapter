module ActiveRecord
  module ConnectionAdapters
    module PostGIS

      module ColumnMethods
        include PostgreSQL::ColumnMethods

        def geometry(*args, **options)
          args.each { |name| column(name, :geometry, options) }
        end

      end

      class TableDefinition < ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition
        include PostGIS::ColumnMethods
      end

    end
  end
end