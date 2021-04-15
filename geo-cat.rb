#!/usr/bin/env ruby
# geo-cat.rb
# Concatenates GeoJSON files

require 'json'

help = proc do
  puts "Usage: geo-cat.rb [-fn] [-d source_dir] [-r result_file]
  -f - Formatted output
  -n - Store filename in feature properties"
  exit 0
end

# GeoJSON object
class GeoJSON
  # Creating empty GeoJSON feature collection
  def initialize
    @collection = { 'type' => 'FeatureCollection', 'features' => [] }
  end

  # Adding features from GeoJSON file to object collection
  def add(filename, add_name)
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
    # Adding name to feature
    feature_name(filename) if add_name
  rescue StandardError => e
    puts "Error #{e} in #{filename}"
  end

  # Saving object collection to GeoJSON file
  # Use 'pretty: true' to generate formatted output
  def save(opt)
    File.open(opt[:result], 'w') do |f|
      opt[:pretty] == true ? f.write(JSON.pretty_generate(@collection)) : f.write(JSON.generate(@collection))
    end
  end

  private

  def feature_name(filename)
    name = File.basename(filename, File.extname(filename)) # Removing extension from filename
    @collection['features'].last['properties'] = { 'name' => name }
  end
end

# Checking arguments and setting options
options = { mask: '*.geojson', result: 'result.geojson', pretty: false, add_name: false }
unless ARGV.empty?
  ARGV.each_with_index do |argument, id|
    if argument == '-d' && !ARGV[id + 1].nil?
      options[:mask] = "#{ARGV[id + 1]}/*.geojson"
      options[:result] = "#{ARGV[id + 1]}/result.geojson" if options[:result] == 'result.geojson'
    elsif argument == '-r' && !ARGV[id + 1].nil?
      options[:result] = ARGV[id + 1]
    elsif argument.chars.first == '-'
      argument.each_char do |arg_char|
        case arg_char
        when 'f'
          options[:pretty] = true
        when 'n'
          options[:add_name] = true
        when '?', 'h'
          help.call
        end
      end
    end
  end
end

collection = GeoJSON.new

# Getting .geojson files from directory
source_files = Dir[options[:mask]]
# Removing result file
source_files -= [options[:result]]

if source_files.empty?
  puts 'Can\'t find .geojson files'
  exit 0
end

puts "Parsing #{source_files.length} file(s)"
source_files.each do |geojson_file|
  collection.add(geojson_file, options[:add_name])
end

puts "Saving #{options[:result]}"
collection.save(options)
