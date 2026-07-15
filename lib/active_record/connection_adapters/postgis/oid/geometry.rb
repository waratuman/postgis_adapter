require 'rgeo'

module ActiveRecord
  module ConnectionAdapters
    module PostGIS
      module OID

        class Geometry < Type::Value
          include ActiveModel::Type::Helpers::Mutable

          # Build the RGeo factory, parsers and generator once, up front. The
          # SRID is fixed for the column, so these are invariant for the life of
          # the type instance. Doing it here (rather than lazily on each cast)
          # avoids rebuilding a GEOS factory on every value read, and is
          # required because Type instances are frozen after initialization.
          def initialize(...)
            super
            @rgeo_factory = RGeo::Geos.factory(srid: srid)
            @wkb_parser = RGeo::WKRep::WKBParser.new(@rgeo_factory, support_ewkb: true, default_srid: srid)
            @wkt_parser = RGeo::WKRep::WKTParser.new(@rgeo_factory, support_ewkt: true, default_srid: srid)
            @wkb_generator = RGeo::WKRep::WKBGenerator.new(hex_format: true, type_format: :ewkb, emit_ewkb_srid: true)
          end

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
                @wkb_parser.parse(value)
              else
                @wkt_parser.parse(value)
              end
            else
              raise ArgumentError, "Unsupported argument type (#{value.class})"
            end
          end

          def serialize(value)
            case value
            when  RGeo::Feature::Instance
              @wkb_generator.generate(value)
            else
              value
            end
          end

          def changed_in_place?(raw_old_value, new_value)
            cast(raw_old_value) != new_value
          end

          private

          def srid
            limit ? limit[:srid].to_i : 0
          end

        end

      end
    end
  end
end
