require 'cases/helper'
require 'stringio'

class PostGISSchemaDumper < ActiveSupport::TestCase

  def test_geometry_is_a_native_database_type
    assert_includes ActiveRecord::ConnectionAdapters::PostGISAdapter.native_database_types, :geometry
    assert connection.valid_type?(:geometry)
  end

  def test_native_database_types_keeps_the_postgresql_types
    assert_equal connection.class.superclass.native_database_types[:datetime],
      ActiveRecord::ConnectionAdapters::PostGISAdapter.native_database_types[:datetime]
  end

  def test_dumps_tables_with_geometry_columns
    dump = dump_schema

    refute_match(/Could not dump table/, dump)
    assert_match(/t\.geometry\s+"point",\s+limit: \{.*type: "Point".*srid: 4326.*\}/, dump)
  end

  def test_dumps_srid_as_an_integer
    limit = connection.columns(:geos).find { |c| c.name == "point" }.limit

    assert_equal({ type: "Point", srid: 4326 }, limit)
  end

  private

  def connection
    ActiveRecord::Base.lease_connection
  end

  def dump_schema
    io = StringIO.new
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection_pool, io)
    io.string
  end

end
