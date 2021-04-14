#!/usr/bin/env ruby
# geo-cat.rb
# Concatenates GeoJSON files

require 'json'

HELP = "Usage: geo-cat.rb [-f] [-d source_dir] [-r result_file]\n\e[7C-f - Formatted output".freeze

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
  def save(opt)
    File.open(opt[:result], 'w') do |f|
      opt[:pretty] == true ? f.write(JSON.pretty_generate(@collection)) : f.write(JSON.generate(@collection))
    end
  end
end

# Checking arguments
options = { mask: '*.geojson', result: 'result.geojson', pretty: false }
unless ARGV.empty?
  ARGV.each_with_index do |argument, id|
    if %w[/? -? -h --help].include?(argument)
      puts HELP; exit 0
    elsif %w[-d --dir].include?(argument) && !ARGV[id + 1].nil?
      options[:mask] = "#{ARGV[id + 1]}/*.geojson"
      options[:result] = "#{ARGV[id + 1]}/result.geojson" if options[:result] == 'result.geojson'
    elsif %w[-r --result].include?(argument) && !ARGV[id + 1].nil?
      options[:result] = ARGV[id + 1]
    elsif %w[-f --format].include?(argument)
      options[:pretty] = true
    end
  end
end

collection = GeoJSON.new

# Getting .geojson files from directory
source_files = Dir[options[:mask]]
# Removing result file
source_files -= [options[:result]]

source_files.each do |geojson_file|
  puts "Parsing #{geojson_file}"
  collection.add(geojson_file)
end

puts "Saving #{options[:result]}"
collection.save(options)
