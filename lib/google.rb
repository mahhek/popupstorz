require 'utility'

module Google

################################################################################

protected
  def self.resolve_location location_string
    location_string = CGI::escape location_string
    url = URI.parse("http://maps.google.com/")
    res = Net::HTTP.start(url.host, url.port) { |http| 
      http.get("/maps/geo?q=#{location_string}&" + 
        "sensor=true&" + 
        "key=ABQIAAAA2NOo93VS7djjvzZXCw3a3xRiuOlZacYj2HhhRbgtYRUU3MBeuxTDhLyykdgMFsUGXHp35r8B6WL_DQ&" + 
        "output=xml&oe=utf8") 
    }
    res.body
  end

################################################################################

  def self.resolve_address lon, lat
    url = URI.parse("http://maps.google.com/")
    res = Net::HTTP.start(url.host, url.port) { |http| 
      http.get("/maps/api/geocode/xml?latlng=#{lat.to_s},#{lon.to_s}&sensor=false") 
    }
    res.body
  end

################################################################################

  def self.read_locations xml_tree
    ret = []
    # puts xml_tree.inspect
    
    if xml_tree['kml']['Response']['Placemark'].class == Array
      xml_tree['kml']['Response']['Placemark'].each { |pm|
        lon, lat = pm['Point']['coordinates'].split ','
        ret.push({ :address => pm['address'], :coords => [lon, lat] })
      }
    elsif xml_tree['kml']['Response']['Placemark']
      address = xml_tree['kml']['Response']['Placemark']['address']
      coords = xml_tree['kml']['Response']['Placemark']['Point']['coordinates']
      lon, lat = coords.split ','
      ret.push({ :address => address, :coords => [lon, lat] })
    end
    ret
  end

################################################################################

  def self.read_address xml_tree
    # puts xml_tree.inspect

    if xml_tree['GeocodeResponse']['status'] == 'OK'
      return xml_tree['GeocodeResponse']['result'][0]['formatted_address']
    end
    nil
  end

################################################################################

public
  def self.locations_lon_lat location_string
    read_locations(Utility.parse_xml(resolve_location(location_string)))
  end

################################################################################

  def self.locations_address lon, lat
    read_address(Utility.parse_xml(resolve_address(lon, lat)))
  end
end
