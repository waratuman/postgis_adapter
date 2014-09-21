module ActiveRecord
  module ConnectionAdapters
    module PostGIS
      module ColumnMethods

        def geometry(name, options = {})
          column(name, :geometry, options)
        end

      end
    end
  end

end
