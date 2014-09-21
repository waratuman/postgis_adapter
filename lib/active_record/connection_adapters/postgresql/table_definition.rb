module ActiveRecord
  module ConnectionAdapters
    module PostgreSQL
      class TableDefinition < ActiveRecord::ConnectionAdapters::TableDefinition
        include ColumnMethods

      end
    end
  end

end
