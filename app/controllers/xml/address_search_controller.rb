class Xml::AddressSearchController < Xml::XmlController
  def index
    return unless params[:lat] and params[:lon]
    @locations_data = Google.locations_address params[:lon], params[:lat]
    puts "--------------------------------------------------------"
    puts @locations_data.inspect
    render :format => :xml
  end
end