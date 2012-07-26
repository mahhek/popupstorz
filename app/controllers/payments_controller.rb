# -*- encoding : utf-8 -*-
class PaymentsController < ApplicationController

  def new
    @item = Item.find_by_id(params[:item_id])
    @offer = Offer.find_by_id(params[:offer_id])
    @payment = Payment.find_by_offer_id_and_renter_id(@offer.id,current_user.id)

    if @payment.blank?
      @payment = Payment.new
      @map = GMap.new("map")
      @map.control_init(:map_type => false, :small_zoom => true)
      coordinates = [@item.latitude,@item.longitude]
      @map.center_zoom_init(coordinates, 15)
      #      @map.overlay_init(GMarker.new(coordinates,:title => current_user.nil? ? @item.title : current_user.popup_storz_display_name, :info_window => "#{@item.title}"))
    else
      current_user.send_message(@offer.user != current_user ? @offer.user : @item.user, :topic => "Offer Updated", :body => "The <a href='http://#{request.host_with_port}/items/#{@item.id}/offers/#{@offer.id}/edit'>offer</a> you made on #{@item.title} has been modified by #{@offer.user != current_user ? "Owner": "Renter"}. Please review to accept or decline.".html_safe)
      @notification = Notification.new(:user_id => @offer.user != current_user ? @offer.user.id : @item.user.id, :notification_type =>"offer_updated", :description => "The <a href='http://#{request.host_with_port}/items/#{@item.id}/offers/#{@offer.id}/edit'>offer</a> you made on #{@item.title} has been modified by #{@offer.user != current_user ? "Owner": "Renter"}. Please review to accept or decline.".html_safe)
      @notification.save
      flash[:notice] = "You have successfully created a gathering, now waiting for others to join."
      redirect_to "/"
    end

  end

  def create    
    renter = User.find(params[:payment][:renter_id])
    @item = Item.find_by_id(params[:item_id])
    @offer = Offer.find_by_id(params[:offer_id])
    @payment = Payment.new(params[:payment])

    pay_request = PaypalAdaptive::Request.new
    data = {
      "returnUrl" => complete_request_url,
      "requestEnvelope" => {"errorLanguage" => "en_US"},
      "currencyCode"=>"USD",
      "receiverList" => {"receiver"=> [{ "email"=> renter.email.to_s, "amount" => params[:payment][:amount].to_s}]},
      "cancelUrl"=> cancel_request_url,
      "actionType"=>"PAY",
      "startingDate" => Date.today,
      "ipnNotificationUrl"=>"http://localhost:3000/products/ipn_notification"
    }
              
    pay_response = pay_request.preapproval(data)
    if pay_response.success?
      if @offer.is_gathering or @offer.persons_in_gathering.to_i > 0
        gathering_member = GatheringMember.find(:first,:conditions => ["offer_id = ? and user_id = ?",@offer.id,current_user.id])
        if gathering_member.blank?
          @offer.members << current_user
        end
        gathering_member = GatheringMember.find(:first,:conditions => ["offer_id = ? and user_id = ?",@offer.id,current_user.id])
        gathering_member.update_attribute("status","confirmed")
        
        if gathering_member.offer.user_id == current_user.id
          gathering_member.update_attribute("status","Approved")
        end
        
        reqs = GatheringMember.find(:all, :conditions => ["status = 'Approved' and offer_id = #{@offer.id}"])
        if reqs.size == @offer.persons_in_gathering.to_i and @offer.persons_in_gathering == 1
          #          offer.update_attribute("status","joinings approved")
          @offer.update_attribute("status","joinings approved")
        end
        
        check_gathering_state(@offer)
        
        
        owner = User.find(@offer.owner_id)
        user = User.find(@offer.user_id)
        if gathering_member.offer.user_id == current_user.id
          current_user.send_message(owner, :topic => "Gathering", :body => "#{current_user.first_name} has created a gathering for #{@offer.persons_in_gathering} people from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")} at your <a href='http://#{request.host_with_port}/items/#{@offer.item.id}'> #{@offer.item.title} </a> and is now waiting for others to join before sending you an offer. You can check status of the gathering under 'My listings' sub-menu 'Gatherings at my place'".html_safe)
          @notification = Notification.new(:user_id => owner.id, :notification_type =>"Gathering", :description => "#{current_user.first_name} has created a gathering for #{@offer.persons_in_gathering} people from #{@offer.rental_start_date.strftime("%m-%d-%Y")} to #{@offer.rental_end_date.strftime("%m-%d-%Y")} at your <a href='http://#{request.host_with_port}/items/#{@offer.item.id}'> #{@offer.item.title} </a> and is now waiting for others to join before sending you an offer. You can check status of the gathering under 'My listings' sub-menu 'Gatherings at my place'".html_safe)
          @notification.save
          flash[:notice] = "You have successfully created a gathering, now waiting for others to join."
        else
          flash[:notice] = "Successfully applied, waiting for validation from the gathering organizer"
          #        current_user.send_message(user, :topic => "Booking Request", :body => "A new #{current_user.first_name} have applied to join your <a href='http://#{request.host_with_port}/items/#{@offer.item.id}'>gathering</a>".html_safe)
        end
        
      else
        flash[:notice] = "You have successfully applied."
        @offer.update_attribute("status","confirmed")
      end
      
      #      if @offer.is_gathering or @offer.persons_in_gathering.to_i > 0
      
      
      
      redirect_to "/items/#{@item.id}"
    else
      puts pay_response.errors.first['message']
      redirect_to failed_payment_url
    end
    
  end
  
  def check_gathering_state(offer)
    unless offer.members.where("status = ?","confirmed").size.to_i < offer.persons_in_gathering.to_i
      offer.update_attribute("status","Accepted - Confirmation pending")
      recipients = offer.item.user.email
      users = User.all :conditions => ["email in(?)", recipients]
      unless users.blank?
        users.each do |user|
          current_user.send_message(user, :topic => "Gathering Confirmation Request", :body => "Please confirm the gathering as the required members have joined.".html_safe)
          @notification = Notification.new(:user_id => user.id, :notification_type =>"Gathering Confirmation Request", :description => "Please confirm the gathering as the required members have joined.".html_safe)
          @notification.save
        end
      end    
    end
  end
  
  def capture_gathering_commission(offer)
    receivers = []    
    
    #    offers = Offer.find(:all, :conditions => ["status = 'Approved' and parent_id = #{offer.id}"])
    members = GatheringMember.find(:all, :conditions => ["status = 'Approved' and offer_id =  #{offer.id}"])
    
    if offer.persons_in_gathering.to_i <= members.size.to_i
   
      offer.update_attribute("status","Accepted - Payment pending")
      offer.members.each do|mem|
        obj = {"email" => mem.email.to_s, "amount" => ((offer.total_amount.to_f*10)/100).to_s}
        receivers << obj
      end
      pay_request = PaypalAdaptive::Request.new
      data = {
        "returnUrl" => "http://testserver.com/payments/completed_payment_request", 
        "requestEnvelope" => {"errorLanguage" => "en_US"},
        "currencyCode"=>"USD",
        "receiverList" => {"receiver"=> receivers},
        "cancelUrl"=> "http://testserver.com/payments/canceled_payment_request",
        "actionType"=>"PAY",
        "startingDate" => Date.today,
        "ipnNotificationUrl"=>"http://localhost:3000/products/ipn_notification"
      }
    end

  end
  
  def capture_gathering_commission_and_payment(offer)
    commission = ((offer.total_amount.to_f*10)/100).to_s
    transfer_amount = offer.total_amount.to_f - commission.to_f
  end
  
  def capture_offer_commission_and_payment(offer)
    offer.update_attribute(:status, "Paid but waiting for FeedBack")
  end
  
  
end
