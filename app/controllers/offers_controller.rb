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
#    @map.overlay_init(GMarker.new(coordinates,:title => current_user.nil? ? @item.title : current_user.rentareto_display_name, :info_window => "#{@item.title}"))

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
