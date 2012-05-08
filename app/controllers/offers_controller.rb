# -*- encoding : utf-8 -*-
class OffersController < ApplicationController
  def new
    if !user_signed_in?
      session[:item] = params[:item_id]
      session[:return] = params[:return]
      session[:pick_up] = params[:pick_up]
      flash[:notice] = "Please login to continue."
      redirect_to new_user_session_path
    else
      session[:item] = nil
      params[:return] = session[:return] unless session[:return].blank?
      params[:pick_up] = session[:pick_up] unless session[:pick_up].blank?
    end

    @item = Item.find params[:item_id]
    @map = GMap.new("map")
    @map.control_init(:map_type => false, :small_zoom => true)
    coordinates = [@item.latitude,@item.longitude]
    @map.center_zoom_init(coordinates, 15)
    @map.overlay_init(GMarker.new(coordinates,:title => current_user.nil? ? @item.title : current_user.popup_storz_display_name, :info_window => "#{@item.title}"))

    #    @offer = Offer.find_by_item_id_and_user_id_and_status(@item.id ,current_user.id,"Pending")

    if @offer.blank?
      @offer = @item.offers.build
      @offer.offer_messages.build
    end
    @number_of_days = (DateTime.strptime(params[:return], "%m/%d/%Y").to_datetime - DateTime.strptime(params[:pick_up], "%m/%d/%Y").to_datetime).to_i
    @calculated_price = calculate_price(@number_of_days, @item)
  end

  def create

    @offer = Offer.find_by_item_id_and_user_id_and_status(params[:item_id],current_user.id,"Pending")
    @item = Item.find params[:item_id]
    unless @offer.blank?
      params[:offer][:rental_start_date] = DateTime.strptime(params[:offer][:rental_start_date], "%m/%d/%Y").to_time
      params[:offer][:rental_end_date] = DateTime.strptime(params[:offer][:rental_end_date], "%m/%d/%Y").to_time
      params[:offer][:cancellation_date] = DateTime.strptime(params[:offer][:cancellation_date], "%m/%d/%Y").to_time if params[:offer][:cancellation_date] != "mm/dd/yy"

      @offer.update_attributes(params[:offer])
      redirect_to  new_item_offer_payment_path(@item,@offer)
    else
      params[:offer][:rental_start_date] = DateTime.strptime(params[:offer][:rental_start_date], "%m/%d/%Y").to_time
      params[:offer][:rental_end_date] = DateTime.strptime(params[:offer][:rental_end_date], "%m/%d/%Y").to_time
      params[:offer][:cancellation_date] = DateTime.strptime(params[:offer][:cancellation_date], "%m/%d/%Y").to_time if params[:offer][:cancellation_date] != "mm/dd/yy"

      @offer = Offer.new(params[:offer].merge(:item_id => params[:item_id]).merge(:user_id => current_user.id).merge(:status => "pending"))

      if @offer.save!
        session[:return] = nil
        session[:pick_up] = nil
        #        @offer.update_attributes(:cancellation_date => (@offer.updated_at + 24.hours))
        redirect_to  new_item_offer_payment_path(@item,@offer)
      else
        render :new
      end
    end
  end

  def edit
    if !user_signed_in?
      session[:edit_item] = params[:item_id]
      session[:edit_offer] = params[:id]
      flash[:notice] = "Please login to continue."
      redirect_to new_user_session_path
    else
      session[:edit_item] = nil
      session[:edit_offer] = nil
    end

    @item = Item.find params[:item_id]
    @offer = Offer.find params[:id]
    @offer.offer_messages.build
    load_map

  end

  def load_map
    @map = GMap.new("map")
    @map.control_init(:map_type => false, :small_zoom => true)
    coordinates = [@item.latitude,@item.longitude]
    @map.center_zoom_init(coordinates, 15)
    @map.overlay_init(GMarker.new(coordinates,:title => current_user.nil? ? @item.title : current_user.popup_storz_display_name, :info_window => "#{@item.title}"))
  end

  def update
    @item = Item.find params[:item_id]
    @offer = Offer.find params[:id]



    params[:offer][:rental_start_date] = DateTime.strptime(params[:offer][:rental_start_date], "%m/%d/%Y").to_time
    params[:offer][:rental_end_date] = DateTime.strptime(params[:offer][:rental_end_date], "%m/%d/%Y").to_time
    params[:offer][:cancellation_date] = DateTime.strptime(params[:offer][:cancellation_date], "%m/%d/%Y").to_time

    @offer.attributes = params[:offer]


    if @offer.changed?
      if @offer.save
        @notification = Notification.new(:user_id => @offer.user != current_user ? @offer.user.id : @item.user.id, :notification_type =>"offer_updated", :description => "The <a href='#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> you made on #{@item.title} has been modified by #{@offer.user != current_user ? "Owner": "Renter"}. Please review to accept or decline.")
        @notification.save
        flash[:notice] = "Offer updated and notification sent"
        redirect_to "/"
      else
        load_map
        flash[:notice] = "Offer was Not updated Successfully!"
        render :edit
      end
    else
      load_map
      flash[:notice] = "Please change any term to send your suggestion, thanks."
      render :edit
    end
  end

  def accept
    @item = Item.find params[:item_id]
    @offer = Offer.find params[:id]
    payment = @offer.payment
    if payment.purchase("charge").status == 3
      payment.save!
      if current_user.id == @offer.user_id
        @offer.update_attribute("status", "Accepted by renter")
        @item.update_attribute("item_status","Reserved")
        flash[:notice] = "Offer accepted"
        @notification = Notification.new(:user_id => @item.user.id, :notification_type =>"offer_accepted", :description => "The <a href='#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> made by #{@offer.user.popup_storz_display_name} on #{@item.title} has been accepted")
        @notification.save
        redirect_to "/"
      else
        @offer.update_attribute("status", "Accepted by owner")
        @item.update_attribute("item_status","Reserved")
        flash[:notice] = "Offer accepted."
        @notification = Notification.new(:user_id => @offer.user.id, :notification_type =>"offer_accepted", :description => "The <a href='#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> you made on #{@item.title} has been accepted by the owner.")
        @notification.save
        flash[:flash] = "Offer accepted."
        redirect_to "/"
      end
    else
      flash[:flash] = "There is some problem in charging renter card, please contact Administrator, thanks."
      redirect_to "/"
    end
  end

  def decline
    @item = Item.find params[:item_id]
    @offer = Offer.find params[:id]
    if current_user.id == @offer.user_id
      @offer.update_attribute("status", "Decline by renter")
      flash[:notice] = "Offer declined"
      @notification = Notification.new(:user_id => @item.user.id, :notification_type =>"offer_declined", :description => "The <a href='#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> made by #{@offer.user.popup_storz_display_name} on #{@item.title} has been declined")
      @notification.save
    else
      @offer.update_attribute("status", "Decline by owner")
      flash[:notice] = "Offer declined"
      @notification = Notification.new(:user_id => @offer.user.id, :notification_type =>"offer_declined", :description => "The <a href='#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> you made on #{@item.title} has been declined by the owner")
      @notification.save
    end
    redirect_to "/"
  end

  protected

  def calculate_price(number_of_days, item)
    ppm = item.price_per_month.nil? ? 0 : item.price_per_month
    ppw = item.price_per_week.nil? ? 0 : item.price_per_week
    ppd = item.price.nil? ? 0 : item.price

    months = number_of_days/30
    weeks = (number_of_days-(30 * months))/7
    days = number_of_days - (30 * months) - (weeks * 7)
    months * ppm  + weeks * ppw + days * ppd
  end


end
