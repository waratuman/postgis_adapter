require 'cases/helper'

class PostGISSchemaCache < ActiveSupport::TestCase

  def test_yaml_type_round_trip
    assert_geometry_type_round_trip YAML.unsafe_load(YAML.dump(geometry_type))
  end

  def test_marshal_type_round_trip
    assert_geometry_type_round_trip Marshal.load(Marshal.dump(geometry_type))
  end

  def test_yaml_schema_cache_round_trip
    assert_schema_cache_round_trip "schema_cache.yml"
  end

  def test_marshal_schema_cache_round_trip
    assert_schema_cache_round_trip "schema_cache.dump"
  end

  private

  def geometry_type
    ActiveRecord::ConnectionAdapters::PostGIS::OID::Geometry.new(limit: { type: "Point", srid: 4326 })
  end

  # Rails 8.1 began storing each column's cast type in the schema cache, and
  # Column#cast_type only became public in 8.1.4.
  def assert_schema_cache_round_trip(filename)
    unless ActiveRecord::ConnectionAdapters::Column.public_method_defined?(:cast_type)
      skip "Column#cast_type is not public in Active Record #{ActiveRecord.version}"
    end

    Dir.mktmpdir do |dir|
      path = File.join(dir, filename)
      pool = ActiveRecord::Base.connection_pool

      cache = ActiveRecord::ConnectionAdapters::SchemaCache.new
      cache.add(pool, "geos")
      cache.dump_to(path)

      loaded = ActiveRecord::ConnectionAdapters::SchemaCache._load_from(path)
      assert_geometry_type_round_trip loaded.columns_hash(pool, "geos")["point"].cast_type
    end
  end

  def assert_geometry_type_round_trip(type)
    assert_kind_of ActiveRecord::ConnectionAdapters::PostGIS::OID::Geometry, type
    assert_equal({ type: "Point", srid: 4326 }, type.limit)

    point = type.cast("POINT(1 2)")
    assert_equal 4326, point.srid
    assert_equal [1, 2], [point.x, point.y]
    assert_equal point, type.cast(type.serialize(point))
  end

end
