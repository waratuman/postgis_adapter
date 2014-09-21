module ActiveRecord
  module ConnectionAdapters
    module PostgreSQL
      module ColumnMethods

        def geometry(name, options = {})
          column(name, :geometry, options)
        end

      end
    end
  end

end
