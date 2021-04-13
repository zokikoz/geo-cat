#!/usr/bin/env ruby
# geo-cat.rb
# Concatenates GeoJSON files

require 'json'

# GeoJSON object
class GeoJSON
  # Creating empty GeoJSON feature collection
  def initialize
    @collection = { 'type' => 'FeatureCollection', 'features' => [] }
  end

  # Adding features from GeoJSON file to object collection
  def add(filename)
    json_hash = JSON.parse(File.read(filename))
    # Inserting features array elements into object features collection
    json_hash['features'].each do |feature|
      @collection['features'] << feature
    end
  end

  # Saving object collection to GeoJSON file
  # Use 'pretty: true' to generate formatted output
  def save(filename, pretty: false)
    File.open(filename, 'w') do |f|
      pretty == true ? f.write(JSON.pretty_generate(@collection)) : f.write(JSON.generate(@collection))
    end
  end
end

exit 1 if ARGV.empty?

collection = GeoJSON.new

ARGV.each do |geojson_file|
  collection.add(geojson_file)
end

collection.save('result.geojson')
