require 'json'
require 'net/http'
require 'hashie'

GOOGLE_API_KEY = ENV['GOOGLE_API_KEY']
GNAVI_KEY_ID = ENV['GNAVI_KEY_ID']

class Docoqoo
  attr_reader :address
  attr_accessor :lat, :lng
  def initialize(address)
    @address = address

    begin
      local_data.results[0].geometry.location.each do |location|
        # こういうときにsendを使うべきか、instance_variable_setを使うべきか
        # create_attr_accessor location[0], location[1]
        send "#{location[0]}=", location[1]
      end
    rescue
      puts "正しい住所を入力してください"
    end

  end

  def local_data
    Hashie::Mash.new(
        JSON.parse(
            Net::HTTP.get(
                URI.parse(
                    URI.escape(google_maps_url)
                ))))
  end

  def select_restaurant
    if @lat && @lng
      restaurant = fetch_gnavi_data.rest.sample
      store_data = "#{restaurant.name}: "
      store_data += "最寄り駅（#{restaurant.access.station}）, " unless restaurant.access.station.empty?
      store_data += "住所（#{restaurant.address}）"
      store_data
    end
  end

  def fetch_gnavi_data
    Hashie::Mash.new(JSON.parse(Net::HTTP.get(URI.parse(URI.escape(restaurant_url)))))
  end

  def google_maps_url
    @google_maps_url ||= "https://maps.googleapis.com/maps/api/geocode/json?address=#{@address}&key=#{GOOGLE_API_KEY}"
  end

  def restaurant_url
    @restaurant_url ||= "http://api.gnavi.co.jp/RestSearchAPI/20150630/?keyid=#{GNAVI_KEY_ID}&latitude=#{@lat}&longitude=#{@lng}&format=json"
  end

  #def create_attr_accessor(attr, val)
  #  instance_variable_set("@#{attr}", val)
  #end
end
