# -*- encoding : utf-8 -*-
class ItemsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_filter :authenticate_user!, :except => [:set_dates, :exchange_price, :new, :create, :show, :search_via_price_range, :search_keyword, :search_category, :autocomplete_item_city, :autocomplete_item_title]
  autocomplete :item, :title
  autocomplete :item, :city

  def set_dates
    session[:start_date] = params[:start_date]
    session[:end_date] = params[:end_date]
    respond_to do |format|
      format.js do        
        render :nothing => true
      end
    end
  end

  def exchange_price
    exchanged_price = number_to_currency(exchange_currency(params[:calculated_price].to_i, params[:price_unit]),:unit => session[:curr] == "USD" ? "$" : "€", :precision => 0)
    respond_to do |format|
      format.js do
        render :js => "$('#total_price').text('#{exchanged_price}');"
      end
    end
  end

  def add_to_favorite
    @item = Item.find params[:id]
    @user = current_user
    unless @item.users.include?(@user)
      @item.users << @user
    end
    respond_to do |format|
      format.js do
        foo = render_to_string(:partial => 'favorite', :locals => { :item => @item }).to_json
        render :js => "$('#favorite_div_#{@item.id}').html(#{foo});"
      end
    end
  end

  def remove_from_favorite
    @item = Item.find params[:id]
    @user = current_user
    if @item.users.include?(@user)
      @item.users.destroy(@user)
    end
    respond_to do |format|
      format.js do
        foo = render_to_string(:partial => 'favorite', :locals => { :item => @item }).to_json
        render :js => "$('#favorite_div_#{@item.id}').html(#{foo});"
      end
    end
  end

  def remove_from_favorite_on
    @item = Item.find params[:id]
    @user = current_user
    if @item.users.include?(@user)
      @item.users.destroy(@user)
    end
    @items = current_user.favorites
    respond_to do |format|
      format.js do
        foo = render_to_string(:partial => 'favorites', :locals => { :items => @items }).to_json
        render :js => "$('#favorite_div').html(#{foo});"
      end
    end
  end

  def favorites
    @items = current_user.favorites
  end

  def index
    @items = current_user.items
  end
  
  def new

    if session[:items].blank?
      @item =  Item.new
      @map = GMap.new("map")
      @map.control_init(:map_type => true, :small_zoom => true)
      @map.center_zoom_init([48.48, 2.20], 6)
    else
      @item = Item.new(session[:items])
      5.times { @item.avatars.build }
      @map = GMap.new("map")
      @map.control_init(:map_type => true, :small_zoom => false)
      @map.center_zoom_init([48.48, 2.20], 6)
    end
    @countries = Country.all
    @listing_types = ListingType.all :order =>"name asc"
    @availability_options = AvailabilityOption.all
    
  end

  def create
    @countries = Country.all
    @item = Item.new(params[:item])
    @map = GMap.new("map")
    if params[:item][:latitude].blank?
      @map.control_init(:map_type => true, :small_zoom => false)
      @map.center_zoom_init([48.48, 2.20], 6)
    else
      coordinates = [params[:item][:latitude],params[:item][:longitude]]
      @map.center_zoom_init(coordinates, 15)
    end
    if @item.valid?
      if !user_signed_in?
        session[:items] = params[:item]
        flash[:notice] = "Please login to continue."
        redirect_to new_user_session_path
      else
        @item.availability_option_ids = params[:availability_options]
        if @item.save
          @item.update_attribute("item_status","Available")
          session[:items] = nil
          flash[:notice] = "Thanks for adding your space."
          redirect_to new_item_avatar_path(@item)
        else
          @listing_types = ListingType.all :order =>"name asc"
          @availability_options = AvailabilityOption.all
          flash[:notice] = "We couldn't add your space. Please check your listing for missing information."
          render :action => "new"
        end
      end
    else
      @listing_types = ListingType.all :order =>"name asc"
      @availability_options = AvailabilityOption.all
      flash[:notice] = "We couldn't add your space. Please check your listing for missing information."
      render :action => "new"
    end
  end

  def edit
    @countries = Country.all
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
    @countries = Country.all
    @item = Item.find(params[:id])
    @item.availability_option_ids = params[:availability_options]
    if @item.update_attributes(params[:item])
      flash[:notice] = "Thanks for updating your space."
      redirect_to edit_item_avatar_path(@item,@item.avatars.first)
    else
      @listing_types = ListingType.all :order =>"name asc"
      @availability_options = AvailabilityOption.all
      flash[:notice] = "We couldn't update your space. Please check your listing for missing information."
      render :action => "edit"
    end
  end

  def show
    @item = Item.find(params[:id])
    @comment = Comment.new
   
    @user = @item.user
    @map = GMap.new("map")
    @map.control_init(:map_type => true, :small_zoom => true)
    coordinates = [@item.latitude,@item.longitude]
    @map.center_zoom_init(coordinates, 15)
    @map.overlay_init(GMarker.new(coordinates,:title => current_user.nil? ? @item.title : current_user.email, :info_window => "#{@item.title}"))
  end

  def destroy
    @item = Item.find_by_id(params[:id])
    @item.destroy
    flash[:notice] = "Item deleted Successfully!"
    redirect_to items_path
  end


  def search_keyword
    session[:start_date] = nil
    session[:end_date] = nil

    @min_price = Item.minimum("price")
    @max_price = Item.maximum("price")
    conds = "1=1 "
    unless params[:search_from].blank?
      new_time =  DateTime.strptime(params[:search_from], "%m/%d/%Y").to_time
      conds += " AND (availability_from) >= '" + new_time.to_s + "'"
    end
    unless params[:search_to].blank?
      new_time =  DateTime.strptime(params[:search_to], "%m/%d/%Y").to_time + 1.day
      conds += " AND (availability_to) <= '" + new_time.to_s + "'"
    end
    unless params[:location].blank?
     
      conds += " AND (city LIKE  " + "'%%" + "#{params[:location]}" + "%%'" +")"
    end
    
    #    @items = Item.paginate(:page => params[:page], :per_page => 4, :conditions => ["Date(availability_from) >= ? AND Date(availability_to) <= ? AND LOWER(address) LIKE ?","#{params[:search_from].to_date}","#{params[:search_to].to_date}","%#{params[:location].strip.downcase}%"], :order => "price")
    case params[:sort_option]
    when "1"
      order_by = "is_recommended, price DESC"
    when "2"
      order_by = "price DESC"
    when "3"
      order_by = "price ASC"
    when "4"
      order_by = "created_at DESC"
    else
      order_by = "price ASC"
    end
    
    @items = Item.paginate(:page => params[:page], :per_page => 3, :conditions => [ conds ], :order => order_by )
    
    @map = GMap.new("map")
    @map.control_init(:map_type => true, :small_zoom => true)
  
    sorted_latitudes = @items.collect(&:latitude).compact.sort
    sorted_longitudes = @items.collect(&:longitude).compact.sort
    @map.center_zoom_on_bounds_init([[sorted_latitudes.first, sorted_longitudes.first],[sorted_latitudes.last, sorted_longitudes.last]])
  
    if @items.size == 0
      @map.center_zoom_init([39.00, 22.00], 6)
    elsif     @items.size == 1
      @map.center_zoom_init([sorted_latitudes.first, sorted_longitudes.first], 15)
    else
      @items.each do |item|
        coordinates = [item.latitude,item.longitude]
        @map.overlay_init(GMarker.new(coordinates,:title => current_user.nil? ? item.title : current_user.first_name, :info_window => "#{item.title}"))
      end
    end
    @items_with_uniq_cities = Item.select("distinct(city)")

    respond_to do |format|
      format.html
      format.js do
        foo = render_to_string(:partial => 'items', :locals => { :items => @items }).to_json
        render :js => "$('#searched-items-div').html(#{foo});$.setAjaxPagination();"
      end
    end
  
  end

  def search_via_price_range
    @items = Item.paginate(:page => params[:page], :per_page => 2, :conditions => ["price >= ? AND price <= ?", params[:min_price].to_f, params[:max_price].to_f], :order => "price")
    respond_to do |format|
      format.js do
        foo = render_to_string(:partial => 'items', :locals => { :items => @items }).to_json
        render :js => "$('#searched-items-div').html(#{foo});$.setAjaxPagination();"
      end
    end
  end

  def new_comment
   
  end
  
  def add_comment
    @comment = Comment.new(params[:comment])
    @comment.user=current_user
    @item =Item.find(params[:id])
    if @item.comments << @comment
      flash[:notice] = "Comment Added"
      redirect_to "/items/show/#{@item.id}"
    else
      flash[:error] = "Not saved"
      render :show
    end
   
  end

  def listings_home
    
  end
  
  def my_pop_ups
    @offers= current_user.offers
  end

  def overview
    @offers= Offer.find(:all, :conditions => ["owner_id=?",current_user.id])
  end

  def payment_charge
    

    @offer= Offer.find(params[:id])
    @item=@offer.item
    
    payment = @offer.payment
    if payment.purchase("charge").status == 3
      @offer.update_attribute(:status, "Paid but waiting for FeedBack")
      
      @notification = Notification.new(:user_id => @offer.user.id, :notification_type =>"offer_updated", :description => "The <a href='#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> you made on #{@item.title} has been paid but FeedBack is pending!")
      @notification.save
      p "aaaaaaaaaaaaaaaaaaaaaaaaaaa", @notification
      redirect_to "/"
    else
      flash[:flash] = "There is some problem in charging renter card, please contact Administrator, thanks."
      redirect_to "/"
    end
  end

  
end
