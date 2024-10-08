require 'rgeo'

module ActiveRecord
  module ConnectionAdapters
    module PostGIS
      module OID

        class Geometry < Type::Value
          include ActiveModel::Type::Helpers::Mutable

          def type
            :geometry
          end

          def cast(value)
            case value
            when nil
              nil
            when RGeo::Geos::CAPIGeometryMethods
              value
            when ::String # HEXEWKB
              if value[0,1] == "\x00" || value[0,1] == "\x01" || value[0,4] =~ /[0-9a-fA-F]{4}/
                RGeo::WKRep::WKBParser.new(rgeo_factory_generator, support_ewkb: true, default_srid: limit[:srid]).parse(value)
              else
                RGeo::WKRep::WKTParser.new(rgeo_factory_generator, support_ewkt: true, default_srid: limit[:srid]).parse(value)
              end
            else
              raise ArgumentError, "Unsupported argument type (#{value.class})"
            end
          end

          def serialize(value)
            case value
            when  RGeo::Feature::Instance
              ::RGeo::WKRep::WKBGenerator.new(hex_format: true, type_format: :ewkb, emit_ewkb_srid: true).generate(value)
            else
              value
            end
          end

          def changed_in_place?(raw_old_value, new_value)
            cast(raw_old_value) != new_value
          end

          private

          def rgeo_factory_generator
            RGeo::Geos.factory(srid: limit[:srid].to_i)
          end

        end

      end
    end
  end
end
