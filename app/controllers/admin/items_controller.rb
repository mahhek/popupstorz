# -*- encoding : utf-8 -*-
class Admin::ItemsController < ApplicationController
  before_filter :authenticate_admin  
  layout "admin"
  
  def index
    case params[:sort_option]
    when "1"
      order_by = "created_at DESC"
    when "2"
      order_by = "created_at ASC"
    when "3"
      order_by = "price ASC"
    when "4"
      order_by = "price DESC"
    when "5"
      order_by = "city ASC"
    when "6"
      order_by = "country ASC"
    when "7"
      order_by = "listing_type_id ASC"
    when "8"
      order_by = "size ASC"
    when "9"
      order_by = "size DESC"
    when "10"
      order_by = "maximum_members ASC"
    when "11"
      order_by = "title ASC"
    else
      order_by = "created_at DESC"
    end
    @items = Item.all(:order => order_by)
    respond_to do |format|
      format.js do
        foo = render_to_string(:partial => 'items', :locals => {:items => @items }).to_json
        render :js => "$('#admin_items_list').html(#{foo});"
      end
      format.html
    end
  end
  
  def new
    @item = Item.new
    @map = GMap.new("map")
    @map.control_init(:map_type => true, :small_zoom => true)
    @map.center_zoom_init([48.48, 2.20], 6)
    @countries = Country.all
    @listing_types = ListingType.all :order =>"name asc"
    @availability_options = AvailabilityOption.all 
  end

  def create
    @countries = Country.all
    set_values

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
        flash[:notice] = t(:login)
        redirect_to new_user_session_path
      else
        @item.availability_option_ids = params[:availability_options]
        if @item.save
          @item.update_attribute("item_status","Available")
          session[:items] = nil
          flash[:notice] = t(:adding_space)
          redirect_to new_item_avatar_path(@item)
        else
          @listing_types = ListingType.all :order =>"name asc"
          @availability_options = AvailabilityOption.all
          flash[:notice] = t(:cant_add_space)
          render :action => "new"
        end
      end
    else
      @listing_types = ListingType.all :order =>"name asc"
      @availability_options = AvailabilityOption.all
      flash[:notice] = t(:cant_add_space)
      render :action => "new"
    end
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

  def transfer_ownership
    @item = Item.find_by_id(params[:item_id])
    @item.update_attribute(:user_id,params[:user_id])
    redirect_to :back
  end

  def display_on_home
    unless params[:item_id].blank?
      @item = Item.find_by_id(params[:item_id])
      @item.update_attribute(:display_on_home, true)
    else
      @item = Item.find_by_id(params[:new_item_id])
      @item.update_attribute(:display_on_home, false)
    end
    redirect_to :back
  end

  def change_commission_rate
    @item = Item.find_by_id(params[:item_id])
    if params[:guest_commission_rate]
      @item.guest_commission_rate = params[:guest_commission_rate]
    end
    if params[:owner_commission_rate]
      @item.owner_commission_rate = params[:owner_commission_rate]
    end
    @item.specific_commission_changed = true
    @item.save    
    redirect_to admin_item_path(@item)
  end

  def change_rate
    
  end

  def change_all   
    @items = Item.all
    @items.each do |item|
      if params[:guest_commission_rate]
      
        item.guest_commission_rate=params[:guest_commission_rate]
      end
      if params[:owner_commission_rate]

        item.owner_commission_rate=params[:owner_commission_rate]
      end
      if item.specific_commission_changed == false
        item.save
      end
    end
    redirect_to admin_items_path
  end

  def show
    @users = User.all
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
      flash[:notice] = t(:updating)
      redirect_to admin_item_path(@item)
    else
      @listing_types = ListingType.all :order =>"name asc"
      @availability_options = AvailabilityOption.all
      flash[:notice] = t(:cant_update)
      render :action => "edit"
    end
  end
  
  def delete_listings
    @items = Item.all
  end

  def active_inactive
    @item = Item.find_by_id(params[:item_id])
    @item.update_attribute(:is_active,!@item.is_active)
    redirect_to :back
  end

  def offer_activation
    @offer = Offer.find_by_id(params[:offer_id])
    @offer.update_attribute(:is_active,!@offer.is_active)
    redirect_to :back
  end
  
  def destroy
    item = Item.find(params[:id])
    if item.destroy
      flash[:notice] = t(:deleted)
    else
      flash[:notice] = t(:cant_delete)
    end
    redirect_to admin_items_path
  end
  
end
