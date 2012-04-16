class Admin::ItemsController < ApplicationController
  before_filter :authenticate_admin
  
  layout "admin"

  def index
    @items = Item.all
  end

  def show
    @item = Item.find(params[:id])
    @user = @item.user
    @map = GMap.new("map")
    @map.control_init(:map_type => true, :small_zoom => true)
    coordinates = [@item.latitude,@item.longitude]
    @map.center_zoom_init(coordinates, 15)
    @map.overlay_init(GMarker.new(coordinates,:title => current_user.nil? ? @item.title : current_user.email, :info_window => "#{@item.title}"))
  end
  
  def delete_listings
    @items = Item.all
  end
  
  def destroy
    ssss
  end
  
end
