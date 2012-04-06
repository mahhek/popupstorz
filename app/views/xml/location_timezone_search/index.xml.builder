xml.instruct! :xml, :version => '1.0', :encoding => 'UTF-8'
xml.locations {
  @location_data.each { |loc|
    xml.location {
      xml.address   "#{loc[:name]} (#{loc[:country]})"
      xml.longitude loc[:coords][0]
      xml.latitude  loc[:coords][1]
      xml.gmtoffset loc[:gmt_offset]
    }
  }
}
