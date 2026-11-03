# Unreleased

- Support dumping and loading the schema cache with geometry columns (YAML and Marshal)
- Fix schema dump of geometry columns on Rails 8.1
- Build the RGeo factory and parsers once per geometry type instead of on every cast
- Fix crash on geometry columns without a limit
- Coerce the SRID to an integer when generating the `geometry()` column type
- Stop adding `:geometry` to the parent PostgreSQLAdapter's native database types
- Add GitHub Actions CI testing Ruby 3.2-3.4 against Rails 8.0 and 8.1

# Version 6.0.0.1

- Rails 6 support

# Version 0.0.1

- Rails 4.2.0 Support
- PostGIS `geometry` type support