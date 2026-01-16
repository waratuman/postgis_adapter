class Geo < ActiveRecord::Base
end

class CreateModelTables < ActiveRecord::Migration[6.0]

  def self.up
    enable_extension :postgis

    create_table :geos, if_not_exists: true do |t|
      t.geometry :point, limit: { type: 'Point', srid: 4326 }
      t.geometry :linestring, limit: { type: 'LineString', srid: 4326 }
      t.geometry :polygon, limit: { type: 'Polygon', srid: 4326 }
      t.geometry :polygon_with_hole, limit: { type: 'Polygon', srid: 4326 }
      t.geometry :collection, limit: { type: 'GeometryCollection', srid: 4326 }
    end
  end

end

ActiveRecord::Migration.verbose = false

ActiveRecord::Migration.run(CreateModelTables)
