class Xml::LocationTimezoneSearchController < Xml::XmlController

################################################################################

  skip_before_filter :xml_auth, :only => [:index]

################################################################################

  # GET /xml/location_timezone_search.xml
  def index
    return nil unless params[:q]
    # CGI.unescape()
    @location_data = Hose.locations_lat_lon_timeoffset(
      Iconv.conv('ISO-8859-1', 'utf-8', params[:q]), DateTime.parse(params[:d]))

    @location_data = [
      {:name => 'keine Treffer', 
        :country => params[:q], 
        :coords => [0,0], 
        :gmt_offset => 0}] if @location_data.empty?

    render :format => :xml
  end

################################################################################

end
