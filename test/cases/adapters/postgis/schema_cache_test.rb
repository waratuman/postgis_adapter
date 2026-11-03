require 'cases/helper'

class PostGISSchemaCache < ActiveSupport::TestCase

  def test_yaml_schema_cache_round_trip
    assert_schema_cache_round_trip "schema_cache.yml"
  end

  def test_marshal_schema_cache_round_trip
    assert_schema_cache_round_trip "schema_cache.dump"
  end

  private

  def assert_schema_cache_round_trip(filename)
    Dir.mktmpdir do |dir|
      path = File.join(dir, filename)
      pool = ActiveRecord::Base.connection_pool

      cache = ActiveRecord::ConnectionAdapters::SchemaCache.new
      cache.add(pool, "geos")
      cache.dump_to(path)

      loaded = ActiveRecord::ConnectionAdapters::SchemaCache._load_from(path)
      type = loaded.columns_hash(pool, "geos")["point"].cast_type

      assert_kind_of ActiveRecord::ConnectionAdapters::PostGIS::OID::Geometry, type
      assert_equal({ type: "Point", srid: 4326 }, type.limit)

      point = type.cast("POINT(1 2)")
      assert_equal 4326, point.srid
      assert_equal [1, 2], [point.x, point.y]
      assert_equal point, type.cast(type.serialize(point))
    end
  end

end
