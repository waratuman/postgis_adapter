module ActiveRecord
  module ConnectionAdapters
    module PostGIS
      class TableDefinition < ActiveRecord::ConnectionAdapters::TableDefinition
        include ColumnMethods

      end
    end
  end

end
