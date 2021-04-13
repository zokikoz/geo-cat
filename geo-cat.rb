#!/usr/bin/env ruby
# geo-cat.rb
# Concatenates GeoJSON files

require 'json'

new_geojson = { 'type' => 'FeatureCollection', 'features' => [] }

exit 1 if ARGV.empty?

ARGV.each do |geojson_file|
  json_hash = JSON.parse(File.read(geojson_file))
  json_hash['features'].each do |feature|
    new_geojson['features'] << feature
  end
end

file_name = "#{ARGV[0].split('.').first}-plus.geojson"
File.open(file_name, 'w') do |f|
  f.write(JSON.pretty_generate(new_geojson))
end
