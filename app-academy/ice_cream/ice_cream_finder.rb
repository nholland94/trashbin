require 'addressable/uri'
require 'rest-client'
require 'nokogiri'
require 'json'
require 'debugger'

class Location
  attr_accessor :lat, :lng

  def initialize(lat, lng)
    @lat = lat
    @lng = lng
  end

  def to_s
    "#{@lat},#{@lng}"
  end
end

class GoogleAPI
  API_KEY = "AIzaSyCl8XAX4cKAJIO3rhjP3qmui8CO8UXCUWQ"

  def self.places(location)
    places_url = Addressable::URI.new(
      scheme: 'https',
      host: 'maps.googleapis.com',
      path: 'maps/api/place/nearbysearch/json',
      query_values: {
        key: self::API_KEY,
        location: location.to_s,
        radius: "500",
        sensor: "false",
        keyword: "ice cream"
      }
    ).to_s

    JSON::parse(RestClient.get(places_url))
  end

  # object = places_api
  # object["results"].first["geometry"]
  #   ["location"]
  #     ["lat"]
  #     ["lng"]
  #   ["id"]
  #   ["name"]

  def self.geocoding(address)
    geocoded_location = Addressable::URI.new(
      scheme: 'https',
      host: 'maps.googleapis.com',
      path: 'maps/api/geocode/json',
      query_values: {
        address: address,
        sensor: "false"
      }
    ).to_s

    JSON::parse(RestClient.get(geocoded_location))
  end

  # object["results"].first["geometry"]["location"]

  def self.directions(start_location, end_location)

    directions = Addressable::URI.new(
      scheme: 'https',
      host: 'maps.googleapis.com',
      path: 'maps/api/directions/json',
      query_values: {
        origin: start_location.to_s,
        destination: end_location.to_s,
        sensor: "false"
      }
    ).to_s

    JSON::parse(RestClient.get(directions))
  end
end

puts "What is your address?"
locs = GoogleAPI.geocoding(gets.chomp)["results"].first["geometry"]["location"]
origin = Location.new(locs["lat"], locs["lng"])

nearest_places = GoogleAPI.places(origin)

nearest_places["results"][0..4].each_with_index do |place, index|
  puts "#{index+1}: #{place["name"]}"
end

puts "Where would you like to go?"
selection = gets.chomp.to_i - 1

locs = nearest_places["results"][selection]["geometry"]["location"]
destination = Location.new(locs["lat"], locs["lng"])

directions = GoogleAPI.directions(origin, destination)
directions["routes"].first["legs"].first["steps"].each do |step|
  html = Nokogiri::HTML(step["html_instructions"])
  html.css('div').each { |div| div.replace "\n#{div}" }
  puts html.text
end