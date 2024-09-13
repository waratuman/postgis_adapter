require 'cases/helper'

class PostGISGeometry < ActiveSupport::TestCase # ActiveRecord::PostGISTestCase

  def test_point
    geo = Geo.create(point: 'POINT(0 0)')
    assert geo.point.is_a?(RGeo::Geos::CAPIPointImpl)
    assert_equal 0, geo.point.x
    assert_equal 0, geo.point.y
  end

  def test_linestring
    geo = Geo.create(linestring: 'LINESTRING(0 0, 1 1, 2 1, 2 2)')
    assert geo.linestring.is_a?(RGeo::Geos::CAPILineStringImpl)
    assert_equal "LINESTRING (0 0, 1 1, 2 1, 2 2)", geo.linestring.as_text
  end

  def test_polygon
    geo = Geo.create(polygon: 'POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))')
    assert geo.polygon.is_a?(RGeo::Geos::CAPIPolygonImpl)
    assert_equal "POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))", geo.polygon.as_text
  end

  def test_polygon_with_hole
    geo = Geo.create(polygon_with_hole: 'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0),(1 1, 1 2, 2 2, 2 1, 1 1))')
    assert geo.polygon_with_hole.is_a?(RGeo::Geos::CAPIPolygonImpl)
    assert_equal "POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0), (1 1, 1 2, 2 2, 2 1, 1 1))", geo.polygon_with_hole.as_text
  end

  def test_polygon_with_hole
    geo = Geo.create(collection: 'GEOMETRYCOLLECTION(POINT(2 0),POLYGON((0 0, 1 0, 1 1, 0 1, 0 0)))')
    assert geo.collection.is_a?(RGeo::Geos::CAPIGeometryCollectionImpl)
    assert_equal "GEOMETRYCOLLECTION (POINT (2 0), POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0)))", geo.collection.as_text
  end

end
