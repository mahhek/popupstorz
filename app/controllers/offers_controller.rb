# -*- encoding : utf-8 -*-
class OffersController < ApplicationController
  
  def show
    @comment = Comment.new
    @offer = Offer.find(params[:id])
    if @offer.blank?
      flash[:notice] = t(:no_gathering_found)
      redirect_to "/"
    end    
  end
  
  def new
    if !user_signed_in?
      session[:item] = params[:item_id]
      session[:return] = params[:return]
      session[:pick_up] = params[:pick_up]
      flash[:notice] = t(:login)
      redirect_to new_user_session_path
    else
      session[:item] = nil
      params[:return] = session[:return] unless session[:return].blank?
      params[:pick_up] = session[:pick_up] unless session[:pick_up].blank?
    end

    session[:start_date] = nil
    session[:end_date] = nil
    
    @item = Item.find params[:item_id]
    
    @booked_dates = []
    @manage_dates_array = []
    @offers = @item.offers.where("(status LIKE '%Confirmed%') and parent_id is NULL")
    @offers.each do|offer|
      @booked_dates << offer.rental_start_date.strftime("%m/%d/%Y").to_s.strip+" to "+offer.rental_end_date.strftime("%m/%d/%Y").to_s.strip
    end
    @manage_dates_array << @booked_dates
    
    @map = GMap.new("map")
    @map.control_init(:map_type => false, :small_zoom => true)
    coordinates = [@item.latitude,@item.longitude]
    @map.center_zoom_init(coordinates, 15)
    @map.overlay_init(GMarker.new(coordinates,:title => current_user.nil? ? @item.title : current_user.popup_storz_display_name, :info_window => "#{@item.title}"))

    #    @offer = Offer.find_by_item_id_and_user_id_and_status(@item.id ,current_user.id,"Pending")
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
    
    if @offer.blank?
      @offer = @item.offers.build
      @offer.offer_messages.build
    end
    @number_of_days = (DateTime.strptime(params[:return], "%m/%d/%Y").to_datetime - DateTime.strptime(params[:pick_up], "%m/%d/%Y").to_datetime).to_i
    @number_of_days += 1
    @calculated_price = calculate_price(@number_of_days, @item)
  end

  def create
    
    @offer = Offer.find_by_item_id_and_user_id_and_status(params[:item_id],current_user.id,"Pending")
    @item = Item.find params[:item_id]
    
    @booked_dates = []
    @manage_dates_array = []
    #    offers = @item.offers(:conditions => ["status != 'applied' and parent_id is NULL"])    
    @offers = @item.offers.where("(status LIKE '%Confirmed%') and parent_id is NULL")
    @offers.each do|offer|
      @booked_dates << offer.rental_start_date.strftime("%m/%d/%Y").to_s.strip+" to "+offer.rental_end_date.strftime("%m/%d/%Y").to_s.strip
    end
    @manage_dates_array << @booked_dates
    
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
      if params[:offer][:gathering_deadline] != "mm/dd/yy" and !params[:offer][:gathering_deadline].blank?
        params[:offer][:gathering_deadline] = DateTime.strptime(params[:offer][:gathering_deadline], "%m/%d/%Y").to_time
      end
      
      params[:offer][:additional_message] = params[:offer][:offer_messages_attributes]
            
      @offer = Offer.new(params[:offer].merge(:item_id => params[:item_id]).merge(:user_id => current_user.id).merge(:status => "pending"))

      if @offer.save!
        session[:return] = nil
        session[:pick_up] = nil
        
        @offer.update_attribute(:status, "Applied")
        #        if !params[:offer].blank? && !params[:offer][:offer_messages_attributes].blank?
        #          params[:offer][:offer_messages_attributes].each do|k,v|     
        #            current_user.send_message(@item.user, :topic => "Booking Message", :body => "#{v[:message]}".html_safe)
        #            @notification = Notification.new(:user_id => @item.user.id, :notification_type =>"Booking Message", :description => "#{v[:message]}".html_safe)
        #            @notification.save
        #          end
        #        end
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
      flash[:notice] = t(:login)
      redirect_to new_user_session_path
    else
      session[:edit_item] = nil
      session[:edit_offer] = nil
    end
    @comment = Comment.new
    @item = Item.find params[:item_id]
    
    @booked_dates = []
    @manage_dates_array = []
    @offers = @item.offers.where("(status LIKE '%Confirmed%') and parent_id is NULL")   
    offers.each do|offer|
      @booked_dates << offer.rental_start_date.strftime("%m/%d/%Y").to_s.strip+" to "+offer.rental_end_date.strftime("%m/%d/%Y").to_s.strip
    end
    @manage_dates_array << @booked_dates
    
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

    @booked_dates = []
    @manage_dates_array = []
    @offers = @item.offers.where("(status LIKE '%Confirmed%') and parent_id is NULL")
    offers.each do|offer|
      @booked_dates << offer.rental_start_date.strftime("%m/%d/%Y").to_s.strip+" to "+offer.rental_end_date.strftime("%m/%d/%Y").to_s.strip
    end
    @manage_dates_array << @booked_dates

    params[:offer][:rental_start_date] = DateTime.strptime(params[:offer][:rental_start_date], "%m/%d/%Y").to_time
    params[:offer][:rental_end_date] = DateTime.strptime(params[:offer][:rental_end_date], "%m/%d/%Y").to_time
    params[:offer][:cancellation_date] = DateTime.strptime(params[:offer][:cancellation_date], "%m/%d/%Y").to_time

    @offer.attributes = params[:offer]


    if @offer.changed?
      if @offer.save
        current_user.send_message(@offer.user != current_user ? @offer.user : @item.user, :topic => "Offer Updated", :body => "The <a href='http://#{request.host_with_port}/#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> you made on #{@item.title} has been modified by #{@offer.user != current_user ? "Owner": "Renter"}. Please review to accept or decline.".html_safe)
        @notification = Notification.new(:user_id => @offer.user != current_user ? @offer.user.id : @item.user.id, :notification_type =>"Offer Updated", :description => "The <a href='http://#{request.host_with_port}/#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> you made on #{@item.title} has been modified by #{@offer.user != current_user ? "Owner": "Renter"}. Please review to accept or decline.".html_safe)
        @notification.save
        flash[:notice] = t(:offer_updated)
        redirect_to "/"
      else
        load_map
        flash[:notice] = t(:offer_not_updated)
        render :edit
      end
    else
      load_map
      flash[:notice] = t(:send_suggestion)
      render :edit
    end
  end

  def accept
    unless params[:item_id].blank?
      @item = Item.find params[:item_id]
    end
    @offer = Offer.find params[:id]
    payment = @offer.payment
    #    if payment.purchase("charge").status == 3
    #    payment.save!
    if !@offer.is_gathering or @offer.persons_in_gathering.to_i == 0
      unless @item.blank?        
        if current_user.id == @offer.user_id
          @item.update_attribute("item_status","Reserved")
          flash[:notice] = t(:accepting_offer)
          current_user.send_message(@offer.user, :topic => "Offer Accepted", :body => "#{@offer.item.user.first_name} accepted your offer on #{@offer.item.title} from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")}".html_safe)
          @notification = Notification.new(:user_id => m.user.id, :notification_type =>"Offer Accepted", :description => "#{@offer.item.user.first_name} accepted your offer on #{@offer.item.title} from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")}".html_safe)
          @notification.save
        else
          @item.update_attribute("item_status","Reserved")
          flash[:notice] = t(:accepting_offer)
          current_user.send_message(@offer.user, :topic => "Offer Accepted", :body => "#{@offer.item.user.first_name} accepted your offer on #{@offer.item.title} from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")}".html_safe)
          @notification = Notification.new(:user_id => m.user.id, :notification_type =>"Offer Accepted", :description => "#{@offer.item.user.first_name} accepted your offer on #{@offer.item.title} from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")}".html_safe)
          @notification.save
          flash[:notice] = t(:accepting_offer)
          redirect_to "/"
        end
      else
        current_user.send_message(@offer.user, :topic => "Offer Accepted", :body => "#{@offer.item.user.first_name} accepted your offer on #{@offer.item.title} from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")}".html_safe)
        @notification = Notification.new(:user_id => @offer.user.id, :notification_type =>"Offer Accepted", :description => "#{@offer.item.user.first_name} accepted your offer on #{@offer.item.title} from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")}".html_safe)
        @notification.save
        flash[:notice] = t(:accepting_offer)
      end
      @offer.update_attribute("status", "Confirmed")
    else
      @item = @offer.item
      members = GatheringMember.find(:all, :conditions => "offer_id = #{@offer.id} and status = 'Approved'")
      members.each do|m|
        current_user.send_message(m.user, :topic => "Offer Accepted", :body => "#{@offer.item.user.first_name} accepted your offer on #{@offer.item.title} from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")}".html_safe)
        @notification = Notification.new(:user_id => m.user.id, :notification_type =>"Offer Accepted", :description => "#{@offer.item.user.first_name} accepted your offer on #{@offer.item.title} from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")}".html_safe)
        @notification.save
      end
      @offer.update_attribute("status", "Confirmed")
      flash[:notice] = t(:accepting_offer)
    end
    if @offer.item.user == current_user      
      redirect_to "/items/overview"
    else
      redirect_to "/items/gatherings_at_my_place"
    end
    #    else
    #      flash[:flash] = "There is some problem in charging renter card, please contact Administrator, thanks."
    #      redirect_to "/"
    #    end
  end

  def decline
    @item = Item.find params[:item_id]
    @offer = Offer.find params[:id]
    unless @offer.is_gathering or @offer.persons_in_gathering.to_i > 0
      if current_user.id == @offer.user_id
        @offer.update_attribute("status", "Declined")
        flash[:notice] = t(:offer_declined)
#        current_user.send_message(@item.user, :topic => "Offer Declined", :body => "The <a href='http://#{request.host_with_port}/#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> made by #{@offer.user.popup_storz_display_name} from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")} on #{@item.title} has been declined".html_safe)
        current_user.send_message(@item.user, :topic => "Offer Declined", :body => "The gathering you created at #{@item.title} From #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")} has been cancelled by the owner. We apologize for this inconvenience. You will be fully refunded for all fees you have paid. ".html_safe)
        @notification = Notification.new(:user_id => @item.user.id, :notification_type =>"Offer Declined", :description => "The gathering you created at #{@item.title} From#{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")} has been cancelled by the owner. We apologize for this inconvenience. You will be fully refunded for all fees you have paid. ".html_safe)
        @notification.save
      else
        @offer.update_attribute("status", "Declined")
        flash[:notice] = t(:offer_declined)
#        current_user.send_message(@offer.user, :topic => "Offer Declined", :body => "#{@offer.item.user.first_name} rejected your offer on #{@item.title} from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")}".html_safe)        
        current_user.send_message(@offer.user, :topic => "Offer Declined", :body => "The gathering to which you have applied at #{@item.title} From #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")} has been cancelled by the owner. We apologize for this inconvenience. You will be fully refunded for all fees you have paid.".html_safe)
        @notification = Notification.new(:user_id => @offer.user.id, :notification_type =>"Offer Declined", :description => "The gathering to which you have applied at #{@item.title} From #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")} has been cancelled by the owner. We apologize for this inconvenience. You will be fully refunded for all fees you have paid.".html_safe)
        @notification.save
        
      end
      #      redirect_to "/"
    else      
      @item = @offer.item
      members = GatheringMember.find(:all, :conditions => "offer_id = #{@offer.id} and status = 'Approved'")
      members.each do|m|
        current_user.send_message(m.user, :topic => "Offer Declined", :body => "#{@offer.item.user.first_name} rejected your offer on #{@item.title} from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")}".html_safe)
      end      
      @offer.update_attribute("status", "Declined")
      flash[:notice] = t(:offer_declined)
      #      redirect_to "/items/gatherings_at_my_place"
    end
    if @offer.item.user == current_user
      redirect_to "/items/overview"
    else
      redirect_to "/items/gatherings_at_my_place"
    end
  end

  #  def payment_charge
  #    sdfdsf
  #    if payment.purchase("charge").status == 3
  #    else
  #      flash[:flash] = "There is some problem in charging renter card, please contact Administrator, thanks."
  #      redirect_to "/"
  #    end
  #  end
  
  def join_gathering
    @offer = Offer.find(params[:id])
  end
  
  def join
    @offer = Offer.find(params[:id])
    @item = @offer.item
    message = params[:user_message]
    new_offer = @offer.dup
    new_offer.user_id = current_user.id
    new_offer.parent_id = @offer.id
    new_offer.save
    @offer.members << current_user
    gathering_member = GatheringMember.find(:first,:conditions => ["offer_id = ? and user_id = ?",@offer.id,current_user.id])
    gathering_member.update_attributes({"user_message" => message, "status" => "Applied"})
    
    unless current_user == @offer.user
      current_user.send_message(@offer.user, :topic => "Gathering Application", :body => "#{current_user.popup_storz_display_name} has applied for your <a href='http://#{request.host_with_port}/items/#{@item.id}'> gathering</a> at #{@item.title} from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")}. Please go to My bookings, sub-menu Upcoming, and accept or decline the applicant".html_safe)
      @notification = Notification.new(:user_id => @offer.user_id, :notification_type =>"Gathering Application", :description => "#{current_user.popup_storz_display_name} has applied for your <a href='http://#{request.host_with_port}/items/#{@item.id}'> gathering</a> at #{@item.title} from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")}. Please go to My bookings, sub-menu Upcoming, and accept or decline the applicant".html_safe)
      @notification.save
      
      current_user.send_message(@offer.user, :topic => "User Gathering Message", :body => "#{params[:user_message]}".html_safe)
      @notification = Notification.new(:user_id => @offer.user_id, :notification_type =>"User Gathering Message", :description => "#{params[:user_message]}".html_safe)
      @notification.save
    end    
    redirect_to  new_item_offer_payment_path(@item,@offer)
    #    redirect_to "/items/show/#{offer.item_id}"
  end
  
  def approve_gathering_request
    offer = Offer.find(params[:id])
    if offer.is_gathering or offer.persons_in_gathering.to_i > 0
      
      gathering_member = GatheringMember.find(:first, :conditions => ["offer_id = ? and user_id = ?",params[:id],params[:mem]])
      gathering_member.update_attribute("status", "Approved")
      
      new_offer = Offer.new
      new_offer = offer.dup
      new_offer.parent_id = offer.id
      new_offer.user_id = params[:mem]
      new_offer.status = "Approved"
      
      if new_offer.save
        payment = PaymentsController.new
        payment.capture_gathering_commission(offer)
        
        reqs = GatheringMember.find(:all, :conditions => ["status = 'Approved' and offer_id = #{offer.id}"])
        user = User.find(gathering_member.user_id)
        owner = User.find(gathering_member.offer.owner_id)
                
        current_user.send_message(user, :topic => "Joining Approved", :body => "#{current_user.first_name} accepted your offer on #{offer.item.title} from #{offer.rental_start_date.strftime("%m-%d-%Y")} to #{offer.rental_end_date.strftime("%m-%d-%Y")}".html_safe)
        current_user.send_message(owner, :topic => "User Joining Approved", :body => "#{user.popup_storz_display_name} joined the gathering on your place <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> created by #{current_user.popup_storz_display_name} from #{offer.rental_start_date.strftime("%m-%d-%Y")} to #{offer.rental_end_date.strftime("%m-%d-%Y")}".html_safe)
        @notification = Notification.new(:user_id => user.id, :notification_type =>"Joining Approved", :description => "Your joining request for <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> gathering</a> is approved.".html_safe)        
        @notification.save
        @notification1 = Notification.new(:user_id => owner.id, :notification_type =>"User Joining Approved", :description => "#{user.popup_storz_display_name} joined the gathering on your place <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> created by #{current_user.popup_storz_display_name} from #{offer.rental_start_date.strftime("%m-%d-%Y")} to #{offer.rental_end_date.strftime("%m-%d-%Y")}".html_safe)
        @notification1.save
        if reqs.size == offer.persons_in_gathering.to_i
          #          offer.update_attribute("status","joinings approved")
          offer.update_attribute("status","all joinings approved")
          current_user.send_message(current_user, :topic => "Send Offer to Owner", :body => "Gathering created at <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> from #{offer.rental_start_date.strftime("%m-%d-%Y")} to #{offer.rental_end_date.strftime("%m-%d-%Y")} is now full, please go to My bookings, sub-menu Upcoming to send offer to owner.".html_safe)
          @notification = Notification.new(:user_id => current_user.id, :notification_type =>"Send Offer to Owner", :description => "Gathering created at <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> from #{offer.rental_start_date.strftime("%m-%d-%Y")} to #{offer.rental_end_date.strftime("%m-%d-%Y")} is now full, please go to My bookings, sub-menu Upcoming to send offer to owner.".html_safe)
          @notification.save#{@offer.item.user.first_name} rejected your offer on #{@item.title} from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")}
          #          flash[:notice] = "Gathering is full now you has to send the offer to owner"
          #          current_user.send_message(owner, :topic => "Gathering Approval Required", :body => "Gathering on your place <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> created by #{user.popup_storz_display_name} requires your approval.".html_safe)
          
        end
        flash[:notice] = t(:offer_accepted)
      else
        flash[:notice] = t(:offer_cant_be_accepted)
      end
    else
      if offer.update_attribute("status", "Confirmed")
        flash[:notice] = t(:offer_accepted)
      else
        flash[:notice] = t(:offer_cant_be_accepted)
      end
    end
    redirect_to "/items/created_coming_gatherings"
  end
  
  def decline_gathering_request
    offer = Offer.find(params[:id])
    if offer.is_gathering
      gathering_member = GatheringMember.find(:first, :conditions => ["offer_id = ? and user_id = ?",params[:id],params[:mem]])
      if gathering_member.destroy
        flash[:notice] = t(:request_declined)
        user = User.find(gathering_member.user_id)
        current_user.send_message(user, :topic => "Joining Declined", :body => "Your joining request for <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> gathering</a> is declined.".html_safe)
        @notification = Notification.new(:user_id => gathering_member.user_id, :notification_type =>"Joining Declined", :description => "Your joining request for <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> gathering</a> is declined.".html_safe)
        @notification.save
      else
        flash[:notice] = t(:request_cant_declined)
      end      
    else
      if offer.update_attribute("status", "Rejected")
        flash[:notice] = t(:offer_rejected)
      else
        flash[:notice] = t(:offer_cant_be_rejected)
      end
    end
    redirect_to gatherings_items_path
  end
  
  def send_gathering_deadline
    @gathering = Offer.find(params[:id])
    if @gathering.status != "all joinings approved"
      flash[:notice] = "Request sent already"
      redirect_to "/items/created_coming_gatherings"
    end
    #    @gathering.offer_messages.build
  end
  
  def update_gathering_deadline    
    offer = Offer.find(params[:offer][:id])
    if offer.status == "all joinings approved"
      params[:offer][:cancellation_date] = DateTime.strptime(params[:offer][:cancellation_date], "%m/%d/%Y").to_time
      offer.update_attributes({"cancellation_date" => params[:offer][:cancellation_date], "status" => "joinings approved"})
      owner = User.find(offer.owner_id)
      unless params[:offer][:offer_messages_attributes].blank?
        params[:offer][:offer_messages_attributes].each do|k,v|
          #          current_user.send_message(owner, :topic => "Gathering Approval Request Message", :body => "Gathering on your place <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> created by #{offer.user.popup_storz_display_name} requires your approval and request message is #{v[:message]}.".html_safe)
          OfferMessage.create(v)
        end
      end
      if offer.offer_messages.last.message.blank?
        current_user.send_message(owner, :topic => "Gathering Approval Required", :body => "#{current_user.first_name} would like to rent your space <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title} </a> from #{offer.rental_start_date.strftime("%m-%d-%Y")} to #{offer.rental_end_date.strftime("%m-%d-%Y")} and needs a response before #{offer.gathering_deadline.strftime("%m-%d-%Y")}. You need to go to 'My Listings', 'Manage Bookings' and Accept or Decline the offer.".html_safe)
      else
        current_user.send_message(owner, :topic => "Gathering Approval Required", :body => "#{current_user.first_name} would like to rent your space <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title} </a> from #{offer.rental_start_date.strftime("%m-%d-%Y")} to #{offer.rental_end_date.strftime("%m-%d-%Y")} and needs a response before #{offer.gathering_deadline.strftime("%m-%d-%Y")}. You need to go to 'My Listings', 'Manage Bookings' and Accept or Decline the offer. #{current_user.first_name} says: #{offer.offer_messages.last.message}.".html_safe)
      end

      @notification = Notification.new(:user_id => owner.id, :notification_type =>"Gathering", :description => "#{current_user.first_name} would like to rent your space <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title} </a> from #{offer.rental_start_date.strftime("%m-%d-%Y")} to #{offer.rental_end_date.strftime("%m-%d-%Y")} and needs a response before #{offer.gathering_deadline.strftime("%m-%d-%Y")}. You need to go to 'My Listings', 'Manage Bookings' and Accept or Decline the offer. #{current_user.first_name} says: #{offer.offer_messages.last.message}.".html_safe)
      @notification.save
      flash[:notice] = t(:offer_sent)
    else
      flash[:notice] = t(:offer_already_sent)
    end
    redirect_to "/items/created_coming_gatherings"
  end
  
  def cancel_booking
    offer = Offer.find(params[:id])
    unless offer.blank?
      if offer.update_attribute("status","Cancelled")
        owner = User.find(offer.owner_id)
        user = User.find(offer.user_id)
        appliers = offer.members.where("status = 'Approved'")
        appliers.each do |u|
          unless u == user
            if current_user.id == offer.owner_id              
#              current_user.send_message(u, :topic => "Gathering Cancelled", :body => "Gathering <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> created by #{user.popup_storz_display_name} for which you have applied, is cancelled by creator.".html_safe)
              current_user.send_message(u, :topic => "Gathering Cancelled", :body => "The gathering to which you have applied at #{offer.item.title} from #{offer.rental_start_date.strftime("%m-%d-%Y")} to #{offer.rental_end_date.strftime("%m-%d-%Y")} has been cancelled by the owner. We apologize for this inconvenience. You will be fully refunded for all fees you have paid.".html_safe)
              @notification = Notification.new(:user_id => u.id, :notification_type =>"Gathering Cancelled", :description => "Gathering <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> created by #{user.popup_storz_display_name} for which you have applied, is cancelled by creator.".html_safe)
            else              
#              current_user.send_message(u, :topic => "Gathering Cancelled", :body => "Gathering <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> created by #{user.popup_storz_display_name} for which you have applied, is cancelled by creator.".html_safe)
              current_user.send_message(u, :topic => "Gathering Cancelled", :body => "The gathering to which you have applied at #{offer.item.title} from #{offer.rental_start_date.strftime("%m-%d-%Y")} to #{offer.rental_end_date.strftime("%m-%d-%Y")} has been cancelled by the creator #{offer.user.popup_storz_display_name}. We apologize for this inconvenience. You will be fully refunded for all fees you have paid. Please try to find a new participant in order to create a new gathering or re-create the same gathering with one participant less.".html_safe)
              @notification = Notification.new(:user_id => u.id, :notification_type =>"Gathering Cancelled", :description => "The gathering to which you have applied at #{offer.item.title} from #{offer.rental_start_date.strftime("%m-%d-%Y")} to #{offer.rental_end_date.strftime("%m-%d-%Y")} has been cancelled by the creator #{offer.user.popup_storz_display_name}. We apologize for this inconvenience. You will be fully refunded for all fees you have paid. Please try to find a new participant in order to create a new gathering or re-create the same gathering with one participant less.".html_safe)
            end            
            @notification.save
          end
        end
         if current_user.id == offer.owner_id      
#        current_user.send_message(owner, :topic => "Gathering Cancelled", :body => "Gathering at your place <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> created by #{user.popup_storz_display_name} is cancelled by user.".html_safe)
        current_user.send_message(owner, :topic => "Gathering Cancelled", :body => "The gathering you created at #{offer.item.title} from #{offer.rental_start_date.strftime("%m-%d-%Y")} to #{offer.rental_end_date.strftime("%m-%d-%Y")} has been cancelled by the owner. We apologize for this inconvenience. You will be fully refunded for all fees you have paid.".html_safe)
        @notification = Notification.new(:user_id => owner.id, :notification_type =>"Gathering Cancelled", :description => "The gathering you created at <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> created by #{user.popup_storz_display_name} has been cancelled by the owner. We apologize for this inconvenience. You will be fully refunded for all fees you have paid.".html_safe)
        @notification.save
         else
           current_user.send_message(owner, :topic => "Gathering Cancelled", :body => "The gathering which was created at your place  #{offer.item.title} created by #{user.popup_storz_display_name} from #{offer.rental_start_date.strftime("%m-%d-%Y")} to #{offer.rental_end_date.strftime("%m-%d-%Y")} has been cancelled by its creator. We apologize for this inconvenience.".html_safe)
        @notification = Notification.new(:user_id => owner.id, :notification_type =>"Gathering Cancelled", :description => "the gathering which was created at your place <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> created by #{user.popup_storz_display_name} has been cancelled by its creator. We apologize for this inconvenience.".html_safe)
        @notification.save
        end 
        current_user.send_message(user, :topic => "Gathering Cancelled", :body => "The gathering you created at #{offer.item.title} from #{offer.rental_start_date.strftime("%m-%d-%Y")} to #{offer.rental_end_date.strftime("%m-%d-%Y")} has been cancelled by the owner. We apologize for this inconvenience. You will be fully refunded for all fees you have paid.".html_safe)
        @notification = Notification.new(:user_id => user.id, :notification_type =>"Gathering Cancelled", :description => "The gathering you created at #{offer.item.title} from #{offer.rental_start_date.strftime("%m-%d-%Y")} to #{offer.rental_end_date.strftime("%m-%d-%Y")} has been cancelled by the owner. We apologize for this inconvenience. You will be fully refunded for all fees you have paid.".html_safe)
        @notification.save
        
        flash[:notice] = t(:booking_cancelled)
      else
        flash[:notice] = t(:booking_cant_be_cancelled)
      end
    end
    redirect_to "/items/created_coming_gatherings"
  end
  
  def add_comment
    @comment = Comment.new(params[:comment])
    @comment.user=current_user
    @offer = Offer.find(params[:id])
    if @offer.comments << @comment
      flash[:notice] = t(:comment_added)
      redirect_to "/offers/#{@offer.id}"
    else
      flash[:error] = t(:not_saved)
      render :show
    end   
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

  def payment_charge
    if payment.purchase("charge").status == 3
    else
      flash[:flash] = t(:problem_charging)
      redirect_to "/"
    end
  end

end
