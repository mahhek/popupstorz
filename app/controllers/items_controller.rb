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
    unless params[:item][:availability_from].blank?
      params[:item][:availability_from] = DateTime.strptime(params[:item][:availability_from], "%m/%d/%Y").to_time
    end
    unless params[:item][:availability_to].blank?
      params[:item][:availability_to] = DateTime.strptime(params[:item][:availability_to], "%m/%d/%Y").to_time
    end
    
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
    
    unless params[:item][:availability_from].blank?
      params[:item][:availability_from] = DateTime.strptime(params[:item][:availability_from], "%m/%d/%Y").to_time
    end
    unless params[:item][:availability_to].blank?
      params[:item][:availability_to] = DateTime.strptime(params[:item][:availability_to], "%m/%d/%Y").to_time
    end
    
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
    @booked_dates = []
    @manage_dates_array = []
    @available_days = []
    
    if @item.availablities_sunday == true
      @available_days << 0
    end
    
    if @item.availablities_monday == true
      @available_days << 1
    end
    
    if @item.availablities_tuesday == true
      @available_days << 2
    end
    
    if @item.availablities_wednesday == true
      @available_days << 3
    end
    
    if @item.availablities_thursday == true
      @available_days << 4
    end
    
    if @item.availablities_friday == true
      @available_days << 5
    end
    
    if @item.availablities_saturday == true
      @available_days << 6
    end
            
    @offers = @item.offers.where("(status LIKE '%Confirmed%') and parent_id is NULL")
    
    @offers.each do|offer|
      @booked_dates << offer.rental_start_date.strftime("%m/%d/%Y").to_s.strip+" to "+offer.rental_end_date.strftime("%m/%d/%Y").to_s.strip
    end
    @manage_dates_array << @booked_dates
        
    @comment = Comment.new
   
    @curr_offers = @item.offers.where("(status NOT LIKE '%Confirmed%' and status != 'Cancelled') and parent_id is NULL")
    
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
  
    conds = "1=1 "
    
    @sizes = Item.select("distinct(size)").where("size is not NULL").order("size ASC")
    @types = ListingType.select("distinct(name), id").where("name is not NULL")
    @shareable = Item.select("distinct(is_shareable)")
    
    unless params[:search_from].blank?
      start_time =  DateTime.strptime(params[:search_from], "%m/%d/%Y").to_date      
      conds += " AND ('#{start_time.to_s}' between rental_start_date and rental_end_date)"
    end
    
    unless params[:search_to].blank?
      end_time =  DateTime.strptime(params[:search_to], "%m/%d/%Y").to_date
      conds += " AND ('#{end_time.to_s}' between rental_start_date and rental_end_date)"
    end
    
    if !params[:search_from].blank? and !params[:search_to].blank? 
      conds += " OR ( ( rental_start_date between '#{start_time.to_s}' and '#{end_time.to_s}') or ( rental_end_date between '#{start_time.to_s}' and '#{end_time.to_s}')  )"
    end
    
    if !params[:search_from].blank? or !params[:search_to].blank? 
      conds += " AND status != 'applied'"
    end
    
    booked_items = []
    unless conds == "1=1 "
      conds += "and parent_id is NULL"
      offers = Offer.find(:all,:conditions => [ conds ])
      offers.each do|offer|
        if params[:location].blank?
          booked_items << offer.item
        else
          booked_items << offer.item(:conditions => ["city LIKE '%#{params[:location]}%'"])
        end
      end
    end
    
    item_conds = "1=1 "
    if !params[:min_price].blank? and !params[:max_price].blank?
      item_conds += "AND price >= #{params[:min_price].to_f} AND price <= #{params[:max_price].to_f}"
    end
    
    unless params[:search_from].blank?
      item_conds += " AND ('#{start_time.to_s}' >= availability_from OR '#{start_time.to_s}' <= availability_to)"      
    end
    
    unless params[:search_to].blank?
      item_conds += " AND ('#{end_time.to_s}' >= availability_from  OR '#{end_time.to_s}' <= availability_to )"      
    end

    unless params[:location].blank?
      item_conds += " AND (city LIKE " + "'%%" + "#{params[:location]}" + "%%'" +")"
    end
        
    unless params[:min_size].blank?
      item_conds += " AND (size >= '#{params[:min_size].to_i}')"
    end
    
    unless params[:max_size].blank?
      item_conds += " AND (size <= '#{params[:max_size].to_i}')"
    end
    
    unless params["types"].blank?
      count = 0
      type_arr = ""
      params["types"].each do|type|        
        if count == 0
          type_arr += " listing_type_id = '#{type}'"
        else
          type_arr += " OR listing_type_id = '#{type}'"
        end
        count += 1
      end
      item_conds += " AND (#{type_arr})"
    end
    unless params[:shareable].blank?
      item_conds += " AND (is_shareable = true)"
    end
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
    
    items = Item.find(:all,:conditions => [ item_conds ], :order => order_by)
    
    @items = items - booked_items
    
#    Items whose owners are active users
    active_items = []  
    @items.each do|item|
      if item.user.is_active == true
        active_items << item
      end
    end    
    @items = active_items
    
    if params[:sort_option].blank?
      @items = @items.sort_by{|e| e[:price]}
    end
    @min_price = @items.blank? ? 0 : @items.first.price
    @max_price = @items.blank? ? 0 : @items.last.price
    @max_price = @max_price.to_f > 10000 ? @max_price : 10000
    if params[:sort_option].blank?
      @items = @items.sort_by{|e| e[:size]}
    end
    session[:start_date] = params[:search_from]
    session[:end_date] = params[:search_to]
    
    #    @items = Item.paginate(:page => params[:page], :per_page => 4, :order => "price")
    
    @items = @items.paginate(:page => params[:page], :per_page => 4 )
    
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
    
    conds = "1=1 "
    conds += "AND price >= #{params[:min_price].to_f} AND price <= #{params[:max_price].to_f}"
    unless params[:city].blank?
      conds += " AND (city LIKE " + "'%%" + "#{params[:city]}" + "%%'" +")"
    end
    @items = Item.paginate(:page => params[:page], :per_page => 2, :conditions => [ conds ], :order => "price")
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
    #    @offers = current_user.offers
    @offers = Offer.find(:all, :conditions => ["user_id = ?",current_user.id])
    @offers = @offers.uniq
  end

  def overview
    @offers = Offer.find(:all, :conditions => ["owner_id = ? and (status = 'joinings approved' or status = 'confirmed' or status = 'Declined' or status = 'Confirmed' or status = 'Cancelled')",current_user.id], :order => "rental_start_date ASC")
  end
  
  def  past_transactions 
    @gatherings = Offer.find(:all, :conditions => ["(owner_id = ? and user_id != ?) and persons_in_gathering is not NULL and parent_id is NULL and rental_end_date < '#{Date.parse("#{Date.today}","%Y-%d-%m")}' and offers.status != 'Applied' and offers.status != 'all joinings approved' and offers.status !='joinings approved'",current_user.id,current_user.id], :order => "rental_start_date ASC")
    gathers = @gatherings.group_by(&:item_id)
    gathers.each do|k,v|
      @gatherings = v
    end
  end
      
  def created_prev_gatherings
    #    @gatherings = Offer.find(:all, :conditions => ["(owner_id != ? and user_id = ?) and persons_in_gathering is not NULL and parent_id is NULL and rental_start_date < '#{Date.parse("#{Date.today}","%Y-%d-%m")}'",current_user.id,current_user.id])     
    @gatherings = Offer.find(:all, :conditions => ["(owner_id != ? and user_id = ?) and persons_in_gathering is not NULL and parent_id is NULL and rental_start_date < '#{Date.parse("#{Date.today}","%Y-%d-%m")}' and offers.status != 'Applied' and offers.status != 'all joinings approved' and offers.status !='joinings approved'",current_user.id,current_user.id], :order => "rental_start_date ASC")
    gathers = @gatherings.group_by(&:item_id)
    gathers.each do|k,v|
      @gatherings = v
    end
    @gatherings = @gatherings + current_user.gatherings.where("persons_in_gathering is not NULL and parent_id is NULL and rental_start_date < '#{Date.parse("#{Date.today}","%Y-%d-%m")}' and offers.status != 'Applied' and offers.status != 'all joinings approved' and offers.status !='joinings approved'", :order => "rental_start_date ASC")
    @gatherings = @gatherings.uniq
    @offers = Offer.find(:all, :conditions => ["(user_id = ? or owner_id = ?) and persons_in_gathering is NULL and is_gathering = false and rental_start_date < '#{Date.parse("#{Date.today}","%Y-%d-%m")}'",current_user.id,current_user.id], :order => "rental_start_date ASC")
  end
  
  def created_coming_gatherings
    @gatherings = Offer.find(:all, :conditions => ["(owner_id != ? and user_id = ?) and persons_in_gathering is not NULL and parent_id is NULL and rental_start_date >= '#{Date.parse("#{Date.today}","%Y-%d-%m")}'",current_user.id,current_user.id])
    @gatherings = @gatherings + current_user.gatherings.where("owner_id != #{current_user.id} and persons_in_gathering is not NULL and parent_id is NULL and rental_start_date >= '#{Date.parse("#{Date.today}","%Y-%d-%m")}' and offers.status != 'Applied' and offers.status != 'all joinings approved' and offers.status !='joinings approved'", :order => "rental_start_date ASC")
    @gatherings = @gatherings.uniq
    
    #    Gatherings which current user have joined and requests are accepted by creator
    gathering = []
    joined = Offer.find(:all, :conditions => ["owner_id != #{current_user.id} and parent_id is NOT NULL and status = 'Approved'"], :order => "rental_start_date ASC")
    joined.each do |of|
      if current_user.gatherings.include?(of)
        gathering << Offer.find(of.parent_id)
      end
    end
    @gatherings = @gatherings + gathering
    @gatherings = @gatherings.uniq
    
    gathers = current_user.gatherings.where("offers.user_id != #{current_user.id}  and gathering_members.status = 'Approved' and (offers.status = 'Applied' or offers.status = 'all joinings approved' or offers.status ='joinings approved')", :order => "rental_start_date ASC")
    @gatherings = @gatherings + gathers
    @gatherings = @gatherings.uniq
    
    @offers = Offer.find(:all, :conditions => ["(user_id = ?) and persons_in_gathering is NULL and is_gathering = false and rental_start_date >= '#{Date.parse("#{Date.today}","%Y-%d-%m")}'",current_user.id], :order => "rental_start_date ASC")
    @gatherings = @gatherings + @offers
    
    @gatherings = @gatherings.uniq
    
  end
  
    
  def pending_gathering_acceptance
    @gatherings = current_user.gatherings.where("offers.user_id != #{current_user.id}  and gathering_members.status = 'confirmed' and (offers.status = 'Applied' or offers.status = 'all joinings approved' or offers.status ='joinings approved')", :order => "rental_start_date ASC")
    @gatherings = @gatherings.uniq
  end
  
  def gatherings_at_my_place
    #    @offers = Offer.find(:all, :conditions => ["owner_id = ? and persons_in_gathering is not NULL and parent_id is NULL",current_user.id])
    @offers = Offer.find(:all, :conditions => ["(owner_id = ? and user_id != ?) and persons_in_gathering is not NULL and parent_id is NULL and (status != 'joinings approved' and status != 'Confirmed')",current_user.id,current_user.id], :order => "rental_start_date ASC")
  end
  
  def payment_charge
    @offer = Offer.find(params[:id])
    @item = @offer.item    
    #    payment = @offer.payment
    #    if payment.purchase("charge").status == 3
    #      @offer.update_attribute(:status, "Paid but waiting for FeedBack")
    payment = PaymentsController.new
    if @offer.is_gathering        
      payment.capture_gathering_commission_and_payment(@offer)
    else
      payment.capture_offer_commission_and_payment(@offer)
    end
    if @offer.update_attribute(:status, "Paid but waiting for FeedBack")
      
      current_user.send_message(@offer.user, :topic => "Offer Updated", :body => "The <a href='http://#{request.host_with_port}/#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> you made on #{@item.title} has been paid but FeedBack is pending!".html_safe)
      
      @notification = Notification.new(:user_id => @offer.user.id, :notification_type =>"offer_updated", :description => "The <a href='http://#{request.host_with_port}/#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> you made on #{@item.title} has been paid but FeedBack is pending!".html_safe)
      @notification.save
      redirect_to "/"
    else
      flash[:flash] = "There is some problem in charging renter card, please contact Administrator, thanks."
      redirect_to "/"
    end
  end
end
