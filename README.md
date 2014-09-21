# Ruby on Rails ActiveRecord PostgreSQLAdapter PostGIS Extension

This gem extends the PostgreSQLAdapter to support GIS objects for a PostGIS
database. The RGeo library is used for GIS objects in Ruby.

## PostGIS Extension

- mention PostGIS namespace

## Examples

- migration example
- getter / setter examples
- query examples

create_cities
    t.geometry  :geom, :srid => 4326, :type => 'MultiPolygon'
    

class City
    
end
