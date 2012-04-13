class Xml::LocationSearchController < Xml::XmlController
  def index
    return nil unless params[:q]
    # puts params[:q]
    # puts params[:q].size
    # puts CGI.unescape(params[:q])
    # puts CGI.unescape(params[:q]).size
    
    # @location_data = Google.locations_lon_lat(CGI.unescape(params[:q]))
    @location_data = Google.locations_lon_lat(params[:q])

#    @location_data = [{:address => 'keine Treffer', :coords => [0,0]}] if @location_data.empty?

    render :format => :xml
  end
end
