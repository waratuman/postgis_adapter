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
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::SchemaDumper.ignore_tables |= %w[geometry_columns spatial_ref_sys layer topology]
end