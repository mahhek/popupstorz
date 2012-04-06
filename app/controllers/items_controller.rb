class ItemsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @items = current_user.items
  end
  
  def new
    @item =  Item.new
    5.times { @item.avatars.build }
    @listing_types = ListingType.all :order =>"name asc"
    @availability_options = AvailabilityOption.all 
  end

  def create    
    @item = Item.new(params[:item])
    @item.availability_option_ids = params[:availability_options]
    if @item.save
      flash[:notice] = "Thanks for adding your space."
      redirect_to item_path(@item)
    else
      @listing_types = ListingType.all :order =>"name asc"
      @availability_options = AvailabilityOption.all 
      flash[:notice] = "We couldn't add your space. Please check your listing for missing information."
      render :action => "new"
    end
  end

  def edit
    @item = Item.find_by_id(params[:id])    
    (5 - @item.avatars.size).times { @item.avatars.build }
    @listing_types = ListingType.all :order =>"name asc"
    @availability_options = AvailabilityOption.all
  end

  def update
    @item = Item.find(params[:id])
    @item.availability_option_ids = params[:availability_options]       
    if @item.update_attributes(params[:item])      
      flash[:notice] = "Thanks for updating your space."
      redirect_to item_path(@item)
    else
      @listing_types = ListingType.all :order =>"name asc"
      @availability_options = AvailabilityOption.all 
      flash[:notice] = "We couldn't update your space. Please check your listing for missing information."
      render :action => "edit"
    end
  end

  def show
    @item = Item.find(params[:id])
    @user = @item.user
    #    @map = GMap.new("map")
    #    @map.control_init(:map_type => true, :small_zoom => true)
    #    coordinates = [@item.latitude,@item.longitude]
    #    @map.center_zoom_init(coordinates, 15)
    #    @map.overlay_init(GMarker.new(coordinates,:title => current_user.nil? ? @item.title : current_user.email, :info_window => "#{@item.title}"))
  end

  def destroy
    @item = Item.find_by_id(params[:id])
    @item.destroy
    flash[:notice] = "Item deleted Successfully!"
    redirect_to items_path
  end


  #  def search_keyword
  #
  #    @items = Item.paginate(:page => params[:page], :per_page => 4, :conditions => ["LOWER(title) LIKE ? AND LOWER(address) LIKE ?","%#{params[:keyword].strip.downcase}%","%#{params[:location].strip.downcase}%"], :order => "price")
  #
  #
  #    @map = GMap.new("map")
  #    @map.control_init(:map_type => true, :small_zoom => true)
  #
  #    sorted_latitudes = @items.collect(&:latitude).compact.sort
  #    sorted_longitudes = @items.collect(&:longitude).compact.sort
  #    @map.center_zoom_on_bounds_init([[sorted_latitudes.first, sorted_longitudes.first],[sorted_latitudes.last, sorted_longitudes.last]])
  #
  #    if @items.size == 0
  #      @map.center_zoom_init([39.00, 22.00], 6)
  #    elsif     @items.size == 1
  #      @map.center_zoom_init([sorted_latitudes.first, sorted_longitudes.first], 15)
  #    else
  #      @items.each do |item|
  #        coordinates = [item.latitude,item.longitude]
  #        @map.overlay_init(GMarker.new(coordinates,:title => current_user.nil? ? item.title : current_user.first_name, :info_window => "#{item.title}"))
  #      end
  #    end
  #
  #  end
end
