# -*- encoding : utf-8 -*-
class OffersController < ApplicationController
  
  def show
    @comment = Comment.new
    @offer = Offer.find_by_id(params[:id])
    if @offer.blank?
      flash[:notice] = t(:no_booking_found)
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
    if !params[:return].blank? || !params[:pickup].blank?
      @book_without_dates = false
      @number_of_days = (DateTime.strptime(params[:return], "%m/%d/%Y").to_datetime - DateTime.strptime(params[:pick_up], "%m/%d/%Y").to_datetime).to_i
    else
      @book_without_dates = true
      @number_of_days = 0
    end
    @number_of_days += 1
    @calculated_price = calculate_price(@number_of_days, @item)
  end
 
  def create
    params[:offer][:additional_message] = params[:offer][:offer_messages_attributes]["0"][:message]
    
    @offer = Offer.find_by_item_id_and_user_id_and_status(params[:item_id],current_user.id,"Pending")
    @item = Item.find params[:item_id]
    
    @booked_dates = []
    @manage_dates_array = []
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
    params[:offer][:total_amount] = params[:offer][:grand_total_amount]
    params[:offer].delete(:grand_total_amount)
    
    unless @offer.blank?
      set_dates
      @offer.update_attributes(params[:offer])
      redirect_to new_item_offer_payment_path(@item,@offer)
    else
      set_dates
      if params[:offer][:gathering_deadline] != "mm/dd/yy" and !params[:offer][:gathering_deadline].blank?
        params[:offer][:gathering_deadline] = DateTime.strptime(params[:offer][:gathering_deadline], "%m/%d/%Y").to_time
      end
      
      @offer = Offer.new(params[:offer].merge(:item_id => params[:item_id]).merge(:user_id => current_user.id).merge(:status => "pending"))
      
      if @offer.save!
        session[:return] = nil
        session[:pick_up] = nil        
        @offer.update_attribute(:status, "Applied")
        redirect_to new_item_offer_payment_path(@item,@offer)
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
    @offers.each do|offer|
      @booked_dates << offer.rental_start_date.strftime("%m/%d/%Y").to_s.strip+" to "+offer.rental_end_date.strftime("%m/%d/%Y").to_s.strip
    end
    @manage_dates_array << @booked_dates
    
    @offer = Offer.find params[:id]
    @offer.offer_messages.build
    load_map
  end
  
  def update
    @item = Item.find params[:item_id]
    @offer = Offer.find params[:id]

    @booked_dates = []
    @manage_dates_array = []
    @offers = @item.offers.where("(status LIKE '%Confirmed%') and parent_id is NULL")
    @offers.each do|offer|
      @booked_dates << offer.rental_start_date.strftime("%m/%d/%Y").to_s.strip+" to "+offer.rental_end_date.strftime("%m/%d/%Y").to_s.strip
    end
    @manage_dates_array << @booked_dates    
    set_dates
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

  def set_dates
    params[:offer][:rental_start_date] = DateTime.strptime(params[:offer][:rental_start_date], "%m/%d/%Y").to_time
    params[:offer][:rental_end_date] = DateTime.strptime(params[:offer][:rental_end_date], "%m/%d/%Y").to_time
    params[:offer][:cancellation_date] = DateTime.strptime(params[:offer][:cancellation_date], "%m/%d/%Y").to_time if (params[:offer][:cancellation_date] != "mm/dd/yy" and !params[:offer][:cancellation_date].blank?)
  end
  
  def load_map
    @map = GMap.new("map")
    @map.control_init(:map_type => false, :small_zoom => true)
    coordinates = [@item.latitude,@item.longitude]
    @map.center_zoom_init(coordinates, 15)
    @map.overlay_init(GMarker.new(coordinates,:title => current_user.nil? ? @item.title : current_user.popup_storz_display_name, :info_window => "#{@item.title}"))
  end
  
  def accept
    unless params[:item_id].blank?
      @item = Item.find params[:item_id]
    end
    @offer = Offer.find params[:id]
    payment = @offer.payment
    if !@offer.is_gathering or @offer.persons_in_gathering.to_i == 0
      unless @item.blank?        
        if current_user.id == @offer.user_id
          @item.update_attribute("item_status","Reserved")
          #          flash[:notice] = t(:accepting_offer)
          flash[:notice] = t(:thanks_for)+@offer.user.popup_storz_display_name.to_s
          current_user.send_message(@offer.user, :topic => t(:offer_accepted_email), :body => "#{@offer.item.user.first_name} #{t(:accepted_offer)} #{@offer.item.title} #{t(:email_from)} #{@offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{@offer.rental_end_date.strftime("%b.%d, %Y")}".html_safe)
          @notification = Notification.new(:user_id => m.user.id, :notification_type => t(:offer_accepted_email) , :description => "#{@offer.item.user.first_name} #{t(:accepted_offer)} #{@offer.item.title} #{t(:email_from)} #{@offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{@offer.rental_end_date.strftime("%b.%d, %Y")}".html_safe)
          @notification.save
        else
          @item.update_attribute("item_status","Reserved")
          current_user.send_message(@offer.user, :topic =>  t(:offer_accepted_email) , :body => "#{@offer.item.user.first_name} #{t(:accepted_offer)} #{@offer.item.title} #{t(:email_from)} #{@offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{@offer.rental_end_date.strftime("%b.%d, %Y")}".html_safe)
          @notification = Notification.new(:user_id => m.user.id, :notification_type => t(:offer_accepted_email) , :description => "#{@offer.item.user.first_name} #{t(:accepted_offer)} #{@offer.item.title} #{t(:email_from)} #{@offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{@offer.rental_end_date.strftime("%b.%d, %Y")}".html_safe)
          @notification.save
          #          flash[:notice] = t(:accepting_offer)
          flash[:notice] = t(:thanks_for)+@offer.user.popup_storz_display_name.to_s
          redirect_to "/"
        end
      else
        current_user.send_message(@offer.user, :topic =>  t(:offer_accepted_email) , :body => "#{@offer.item.user.first_name} #{t(:accepted_offer)} #{@offer.item.title} #{t(:email_from)} #{@offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{@offer.rental_end_date.strftime("%b.%d, %Y")}".html_safe)
        @notification = Notification.new(:user_id => @offer.user.id, :notification_type => t(:offer_accepted_email) , :description => "#{@offer.item.user.first_name} #{t(:accepted_offer)} #{@offer.item.title} #{t(:email_from)} #{@offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{@offer.rental_end_date.strftime("%b.%d, %Y")}".html_safe)
        @notification.save
        #        flash[:notice] = t(:accepting_offer)
        flash[:notice] = t(:thanks_for)+@offer.user.popup_storz_display_name.to_s
      end
      @offer.update_attribute("status", "Confirmed")
    else
      @item = @offer.item
      members = GatheringMember.find(:all, :conditions => "offer_id = #{@offer.id} and status = 'Approved'")
      members.each do|m|
        current_user.send_message(m.user, :topic =>  t(:offer_accepted_email) , :body => "#{@offer.item.user.first_name} #{t(:accepted_offer)} #{@offer.item.title} #{t(:email_from)} #{@offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{@offer.rental_end_date.strftime("%b.%d, %Y")}".html_safe)
        @notification = Notification.new(:user_id => m.user.id, :notification_type => t(:offer_accepted_email) , :description => "#{@offer.item.user.first_name} #{t(:accepted_offer)} #{@offer.item.title} #{t(:email_from)} #{@offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{@offer.rental_end_date.strftime("%b.%d, %Y")}".html_safe)
        @notification.save
      end
      @offer.update_attribute("status", "Confirmed")
      #      flash[:notice] = t(:accepting_offer)
      flash[:notice] = t(:thanks_for)+@offer.user.popup_storz_display_name.to_s+t(:in_gathering)
    end
    if @offer.item.user == current_user      
      redirect_to "/items/overview"
    else
      redirect_to "/items/gatherings_at_my_place"
    end
  end

  def decline
    @item = Item.find params[:item_id]
    @offer = Offer.find params[:id]
    unless @offer.is_gathering or @offer.persons_in_gathering.to_i > 0
      if current_user.id == @offer.user_id
        @offer.update_attribute("status", "Declined")
        flash[:notice] = t(:offer_declined)
        current_user.send_message(@item.user, :topic => t(:offer_declined_email) , :body => "#{t(:gathering_created_email)} #{@item.title} #{t(:email_from)} #{@offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{@offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:owner_decliend)} ".html_safe)
        @notification = Notification.new(:user_id => @item.user.id, :notification_type =>t(:offer_declined_email), :description => "#{t(:gathering_created_email)} #{@item.title} #{t(:email_from)} #{@offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{@offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:owner_decliend)}".html_safe)
        @notification.save
      else
        @offer.update_attribute("status", "Declined")
        flash[:notice] = t(:offer_declined)
        current_user.send_message(@offer.user, :topic => t(:offer_declined_email), :body => "#{t(:gathering_applied)} #{@item.title} #{t(:email_from)} #{@offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{@offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:owner_declined_apology_without_payment)}".html_safe)
        @notification = Notification.new(:user_id => @offer.user.id, :notification_type =>t(:offer_declined_email), :description => "#{t(:gathering_applied)} #{@item.title} #{t(:email_from)} #{@offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{@offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:owner_declined_apology_without_payment)}".html_safe)
        @notification.save        
      end
    else
      @item = @offer.item
      members = GatheringMember.find(:all, :conditions => "offer_id = #{@offer.id} and status = 'Approved'")
      members.each do|m|
        current_user.send_message(m.user, :topic => t(:offer_declined_email), :body => "#{@offer.item.user.first_name} #{t(:reject_place)} #{@item.title} #{t(:email_from)} #{@offer.rental_start_date.strftime("%m-%d-%Y")} #{t(:email_to)} #{@offer.rental_end_date.strftime("%m-%d-%Y")}".html_safe)
      end      
      @offer.update_attribute("status", "Declined")
      flash[:notice] = t(:offer_declined)
    end
    if @offer.item.user == current_user
      redirect_to "/items/overview"
    else
      redirect_to "/items/gatherings_at_my_place"
    end
  end
  
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
      current_user.send_message(@offer.user, :topic => t(:app_gathering), :body => "#{current_user.popup_storz_display_name} #{t(:applied_for_email)} <a href='http://#{request.host_with_port}/items/#{@item.id}'> #{t(:gathering_email)} </a> #{t(:on_the_place)} #{@item.title} #{t(:email_from)} #{@offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{@offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:go_to_dashboard)}".html_safe)
      @notification = Notification.new(:user_id => @offer.user_id, :notification_type =>t(:app_gathering), :description => "#{current_user.popup_storz_display_name} #{t(:applied_for_email)} <a href='http://#{request.host_with_port}/items/#{@item.id}'> #{t(:gathering_email)} </a> #{t(:on_the_place)} #{@item.title} #{t(:email_from)} #{@offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{@offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:go_to_dashboard)}".html_safe)
      @notification.save
      
      current_user.send_message(@offer.user, :topic => t(:user_gathering_msg), :body => "#{params[:user_message]}".html_safe)
      @notification = Notification.new(:user_id => @offer.user_id, :notification_type =>t(:user_gathering_msg), :description => "#{params[:user_message]}".html_safe)
      @notification.save
    end    
    redirect_to  new_item_offer_payment_path(@item,@offer)
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
                
        current_user.send_message(user, :topic => t(:join_approve_email), :body => "#{current_user.first_name} #{t(:offer_on_place)} #{offer.item.title} #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")}".html_safe)
        current_user.send_message(owner, :topic => t(:user_join_email), :body => "#{user.popup_storz_display_name} #{t(:join_gathering_place)} <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> #{t(:created_email_by)} #{current_user.popup_storz_display_name} #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")}".html_safe)
        @notification = Notification.new(:user_id => user.id, :notification_type => t(:join_approve_email), :description => "#{t(:our_request)} <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{t(:join_gathering)}</a> #{t(:email_approved)}".html_safe)
        @notification.save
        @notification1 = Notification.new(:user_id => owner.id, :notification_type => t(:user_join_email), :description => "#{user.popup_storz_display_name} joined the gathering on your place <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> #{t(:created_email_by)} #{current_user.popup_storz_display_name} #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")}".html_safe)
        @notification1.save
        if reqs.size == offer.persons_in_gathering.to_i
          offer.update_attribute("status","all joinings approved")
          current_user.send_message(current_user, :topic => t(:send_offer_owner), :body => "#{t(:req_no_mem)} <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:has_been)}".html_safe)
          @notification = Notification.new(:user_id => current_user.id, :notification_type => t(:send_offer_owner), :description => "#{t(:req_no_mem)} <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:has_been)}".html_safe)
          @notification.save          
        end
        if current_user == owner
          flash[:notice] = t(:thanks_for_accepting_offer)+ offer.item.title
        else
          flash[:notice] = t(:thanks_for)+ user.popup_storz_display_name.to_s + t(:in_gathering)
        end
      else
        flash[:notice] = t(:offer_cant_be_accepted)
      end
    else
      if offer.update_attribute("status", "Confirmed")
        flash[:notice] = t(:thanks_for) + t(:offer)
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
        current_user.send_message(user, :topic => t(:joining_decline), :body => "#{t(:req_to_join)} <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{t(:join_gathering)}</a> #{offer.item.title} from #{offer.rental_start_date.strftime("%b. %d ,%Y")} to #{offer.rental_end_date.strftime("%b. %d ,%Y")} #{t(:has_been_declined)}".html_safe)
        @notification = Notification.new(:user_id => gathering_member.user_id, :notification_type => t(:joining_decline), :description => "#{t(:req_to_join)} <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{t(:join_gathering)} </a> #{offer.item.title} from #{offer.rental_start_date.strftime("%b. %d ,%Y")} to #{offer.rental_end_date.strftime("%b. %d ,%Y")} #{t(:has_been_declined)}".html_safe)
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
    redirect_to "/items/created_coming_gatherings"
  end
  
  def send_gathering_deadline
    @gathering = Offer.find(params[:id])
    if @gathering.status != "all joinings approved"
      flash[:notice] = "Request sent already"
      redirect_to "/items/created_coming_gatherings"
    end
  end
  
  def update_gathering_deadline
    offer = Offer.find(params[:offer][:id])
    if offer.status == "all joinings approved"
      params[:offer][:cancellation_date] = DateTime.strptime(params[:offer][:cancellation_date], "%m/%d/%Y").to_time
      offer.update_attributes({"cancellation_date" => params[:offer][:cancellation_date], "status" => "joinings approved"})
      owner = User.find(offer.owner_id)
      unless params[:offer][:offer_messages_attributes].blank?
        params[:offer][:offer_messages_attributes].each do|k,v|
          OfferMessage.create(v)
        end
      end
      if offer.offer_messages.last.message.blank?
        current_user.send_message(owner, :topic => t(:approval_req), :body => "#{current_user.first_name} #{t(:rent_place)} <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title} </a> #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:need_answer)}#{offer.gathering_deadline.strftime("%b.%d, %Y")} #{t(:manage_booking)}".html_safe)
        @notification = Notification.new(:user_id => owner.id, :notification_type => t(:rent_gathering), :description => "#{current_user.first_name} #{t(:rent_place)}  <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title} </a> #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:need_answer)} #{offer.gathering_deadline.strftime("%b.%d, %Y")}#{t(:manage_booking2)}".html_safe)
      else
        current_user.send_message(owner, :topic => t(:approval_req), :body => "#{current_user.first_name} #{t(:rent_place)} <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title} </a> #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:need_answer)} #{offer.gathering_deadline.strftime("%b.%d, %Y")}#{t(:manage_booking)} #{t(:email_from)} #{current_user.first_name}: #{offer.offer_messages.last.message}.".html_safe)
        @notification = Notification.new(:user_id => owner.id, :notification_type => t(:rent_gathering), :description => "#{current_user.first_name} #{t(:rent_place)}  <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title} </a> #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:need_answer)} #{offer.gathering_deadline.strftime("%b.%d, %Y")}#{t(:manage_booking2)} #{t(:email_from)} #{current_user.first_name}: #{offer.offer_messages.last.message}.".html_safe)
      end
      
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
              current_user.send_message(u, :topic => t(:gather_cancelled_email), :body => "#{t(:gather_to_email)} #{offer.item.title} #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")}#{t(:owner_cancelled)}".html_safe)
              @notification = Notification.new(:user_id => u.id, :notification_type =>t(:gather_cancelled_email), :description => "#{t(:the_gathering)} <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> #{t(:created_email_by)} #{user.popup_storz_display_name} #{t(:creator_cancelled)}".html_safe)
            else
              current_user.send_message(u, :topic => t(:gather_cancelled_email), :body => "#{t(:gather_to_email)} #{offer.item.title} #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:cancelled2)} #{offer.user.popup_storz_display_name}#{t(:apology)}".html_safe)
              @notification = Notification.new(:user_id => u.id, :notification_type =>t(:gather_cancelled_email), :description => "#{t(:gather_to_email)}#{offer.item.title} #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:cancelled2)} #{offer.user.popup_storz_display_name} #{t(:apology)}".html_safe)
            end            
            @notification.save
          end
        end
        if current_user.id == offer.owner_id
          current_user.send_message(owner, :topic => t(:gather_cancelled_email), :body => " #{t(:gathering_on_your_place)} #{offer.item.title} #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:cancelled_by_you_owner)}".html_safe)
          @notification = Notification.new(:user_id => owner.id, :notification_type =>t(:gather_cancelled_email), :description => "#{t(:gathering_created_email2)} <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> #{t(:by)} #{user.popup_storz_display_name} #{t(:cancelled_by_you_owner)}".html_safe)
          @notification.save          
        else
          current_user.send_message(owner, :topic => t(:gather_cancelled_email), :body => "#{t(:gathering_on_your_place)}  #{offer.item.title} #{t(:by)} #{user.popup_storz_display_name} #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:creator_cancelled_apology)}".html_safe)
          @notification = Notification.new(:user_id => owner.id, :notification_type =>t(:gather_cancelled_email), :description => "#{t(:gathering_on_your_place)} <a href='http://#{request.host_with_port}/items/#{offer.item.id}'> #{offer.item.title}</a> #{t(:by)} #{user.popup_storz_display_name} #{t(:creator_cancelled_apology)}".html_safe)
          @notification.save
        end
        
        if current_user == user
          current_user.send_message(user, :topic => t(:gather_cancelled_email), :body => "#{t(:gathering_created_email2)} #{offer.item.title} #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:cancelled_by_you)}".html_safe)
          @notification = Notification.new(:user_id => user.id, :notification_type =>t(:gathering_created_email2), :description => "#{t(:gathering_created_email2)} #{offer.item.title} #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:cancelled_by_you)}".html_safe)
          @notification.save        
        else
          current_user.send_message(user, :topic => t(:gather_cancelled_email), :body => "#{t(:gathering_created_email2)} #{offer.item.title} #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:owner_cancelled_apology)}".html_safe)
          @notification = Notification.new(:user_id => user.id, :notification_type =>t(:gather_cancelled_email), :description => "#{t(:gathering_created_email2)} #{offer.item.title} #{t(:email_from)} #{offer.rental_start_date.strftime("%b.%d, %Y")} #{t(:email_to)} #{offer.rental_end_date.strftime("%b.%d, %Y")} #{t(:owner_cancelled_apology)}".html_safe)
          @notification.save
        end
        
        
        flash[:notice] = t(:booking_cancelled)
      else
        flash[:notice] = t(:booking_cant_be_cancelled)
      end
      if current_user.id == offer.owner_id
        redirect_to "/items/overview"
      else
        redirect_to "/items/created_coming_gatherings"
      end
      
    end
    
  end
  
  def add_comment    
    @comment = Comment.new(params[:comment])
    @comment.user=current_user
    @offer = Offer.find(params[:id])
    @offer.comments << @comment
    respond_to do |format|
      format.js do
        view = render_to_string(:partial => 'comments', :locals => { :comments => @offer.comments.order("created_at DESC") }).to_json
        render :js => "$('#comments_div').html(#{view})"
      end
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