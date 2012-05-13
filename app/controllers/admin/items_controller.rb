# -*- encoding : utf-8 -*-
class Admin::ItemsController < ApplicationController
  before_filter :authenticate_admin
  
  layout "admin"

  def index
    @items = Item.all
  end

  def change_recommendation
    @item = Item.find(params[:item_id])
    @item.update_attribute("is_recommended", !@item.is_recommended)
    respond_to do |format|
      format.js do
        foo = render_to_string(:partial => 'recommendation', :locals => { :item => @item }).to_json
        render :js => "$('#recommendation_div_#{@item.id}').html(#{foo});"
      end
    end
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

  def edit
    @item = Item.find_by_id(params[:id])
    (5 - @item.avatars.size).times { @item.avatars.build }
    @listing_types = ListingType.all :order =>"name asc"
    @availability_options = AvailabilityOption.all
    @map = GMap.new("map")
    @map.control_init(:map_type => true, :small_zoom => true)
    coordinates = [@item.latitude,@item.longitude]
    @map.center_zoom_init(coordinates, 15)
    @map.overlay_init(GMarker.new(coordinates,:title => current_user.email, :info_window => "#{@item.title}"))
  end

  def update
    @item = Item.find(params[:id])
    @item.availability_option_ids = params[:availability_options]
    if @item.update_attributes(params[:item])
      flash[:notice] = "Thanks for updating your space."
      redirect_to admin_item_path(@item)
    else
      @listing_types = ListingType.all :order =>"name asc"
      @availability_options = AvailabilityOption.all
      flash[:notice] = "We couldn't update your space. Please check your listing for missing information."
      render :action => "edit"
    end
  end
  
  def delete_listings
    @items = Item.all
  end
  
  def destroy
    item = Item.find(params[:id])
    if item.destroy
      flash[:notice] = "Item deleted successfully!"
    else
      flash[:notice] = "Item can't be deleted. Please try again or later."
    end
    redirect_to admin_items_path
  end
  
end
