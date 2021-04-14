#!/usr/bin/env ruby
# geo-cat.rb
# Concatenates GeoJSON files

require 'json'

HELP = 'Usage: geo-cat.rb [source_dir] [result_file]'.freeze

# GeoJSON object
class GeoJSON
  # Creating empty GeoJSON feature collection
  def initialize
    @collection = { 'type' => 'FeatureCollection', 'features' => [] }
  end

  # Adding features from GeoJSON file to object collection
  def add(filename)
    json_hash = JSON.parse(File.read(filename))
    raise StandardError, 'Missing GeoJSON data' unless %w[Feature FeatureCollection].include?(json_hash['type'])

    # Inserting features array elements into object features collection
    case json_hash['type']
    when 'FeatureCollection'
      json_hash['features'].each do |feature|
        @collection['features'] << feature
      end
    when 'Feature'
      @collection['features'] << json_hash
    end
  rescue StandardError => e
    puts "#{e} in #{filename}"
  end

  # Saving object collection to GeoJSON file
  # Use 'pretty: true' to generate formatted output
  def save(filename, pretty: false)
    File.open(filename, 'w') do |f|
      pretty == true ? f.write(JSON.pretty_generate(@collection)) : f.write(JSON.generate(@collection))
    end
  end
end

# Checking arguments
options = { mask: '*.geojson', result: 'result.geojson' }
unless ARGV.empty?
  case ARGV.length
  when 1
    if %w[/? -? -h --help].include?(ARGV[0])
      puts HELP; exit 0
    else
      options.merge!({ mask: "#{ARGV[0]}/*.geojson", result: "#{ARGV[0]}/result.geojson" })
    end
  when 2
    options.merge!({ mask: "#{ARGV[0]}/*.geojson", result: ARGV[1] })
  else
    puts HELP; exit 0
  end
end

collection = GeoJSON.new

# Getting .geojson files from directory
source_files = Dir[options[:mask]]
# Removing result file
source_files -= [options[:result]]

source_files.each do |geojson_file|
  collection.add(geojson_file)
end

collection.save(options[:result])
