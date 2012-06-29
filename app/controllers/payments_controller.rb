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
      @notification = Notification.new(:user_id => @offer.user != current_user ? @offer.user.id : @item.user.id, :notification_type =>"offer_updated", :description => "The <a href='http://#{request.host_with_port}/items/#{@item.id}/offers/#{@offer.id}/edit'>offer</a> you made on #{@item.title} has been modified by #{@offer.user != current_user ? "Owner": "Renter"}. Please review to accept or decline.".html_safe)
      @notification.save
      flash[:notice] = "Your suggestion has been sent to owner, thanks."
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
      if @offer.is_gathering        
        gathering_member = GatheringMember.find(:first,:conditions => ["offer_id = ? and user_id = ?",@offer.id,current_user.id])
        if gathering_member.blank?
          @offer.members << current_user
        end
        gathering_member = GatheringMember.find(:first,:conditions => ["offer_id = ? and user_id = ?",@offer.id,current_user.id])
        gathering_member.update_attribute("status","confirmed")
        if gathering_member.user_id == current_user.id
          gathering_member.update_attribute("status","Approved")
        end
        
        reqs = GatheringMember.find(:all, :conditions => ["status = 'Approved' and offer_id = #{@offer.id}"])
        if reqs.size == @offer.persons_in_gathering.to_i
#          offer.update_attribute("status","joinings approved")
          @offer.update_attribute("status","all joinings approved")
        end
        
        check_gathering_state(@offer)
      else
        @offer.update_attribute("status","confirmed")
      end
      
      if @offer.is_gathering or @offer.persons_in_gathering.to_i > 0
        @notification = Notification.new(:user_id => @offer.owner_id, :notification_type =>"gathering_created", :description => "A new <a href='http://#{request.host_with_port}/items/#{@offer.item.id}'>gathering</a> is created by #{current_user.first_name}".html_safe)
        @notification.save
      end
      
      flash[:notice] = "Offer sent successfully!"
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
          current_user.send_message(user, :topic => "Gathering Confirmation Request", :body => "Please confirm the gathering as the required members have joined.")
        end
      end    
    end
  end
  
  
  def capture_gathering_commission(offer)
    receivers = []    
    
    #    offers = Offer.find(:all, :conditions => ["status = 'Approved' and parent_id = #{offer.id}"])
    members = GatheringMember.find(:all, :conditions => ["status = 'Approved'"])
    
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
              
    #    pay_response = pay_request.pay(data)
    ##    p "aaaaaaaaaaaaaaaaa",pay_response.inspect
    ##    f
    #    if pay_response.success?
    #      redirect_to pay_response.approve_paypal_payment_url
    #    end
  end
  
  def capture_gathering_commission_and_payment(offer)
    commission = ((offer.total_amount.to_f*10)/100).to_s
    transfer_amount = offer.total_amount.to_f - commission.to_f
    #    p "aaaaaaaaaaaaaaaaaaa",commission
    #    p "bbbbbbbbbbbbbbbbbbb",transfer_amount
    #    g
    
    #    ff
  end
  
  def capture_offer_commission_and_payment(offer)
    #    a
    offer.update_attribute(:status, "Paid but waiting for FeedBack")
    #    ff
  end
  
  
end
