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
      @notification = Notification.new(:user_id => @offer.user != current_user ? @offer.user.id : @item.user.id, :notification_type =>"offer_updated", :description => "The <a href='/items/#{@item.id}/offers/#{@offer.id}/edit'>offer</a> you made on #{@item.title} has been modified by #{@offer.user != current_user ? "Owner": "Renter"}. Please review to accept or decline.")
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

    #    if @payment.valid? && @payment.purchase("verify")
    #      @payment.save
    #      
    #      @notification = Notification.new(:user_id => @item.user.id, :notification_type =>"offer_sent_to_owner", :description => "You have received an <a href='#{edit_item_offer_url(@item.id,@offer.id)}'>offer</a> from #{current_user.popup_storz_display_name} for the item called #{@item.title}")
    #      @notification.save
    #      flash[:notice] = 'Your Offer Has been sent to Owner of item. Thanks.'
    #      redirect_to root_url
    #    else
    #      render :action => :new
    #    end

    pay_request = PaypalAdaptive::Request.new
    data = {
      "returnUrl" => complete_request_url,
      "requestEnvelope" => {"errorLanguage" => "en_US"},
      "currencyCode"=>"USD",
      "receiverList" => {"receiver"=> [{ "email"=> renter.email.to_s, "amount"=>params[:payment][:amount].to_s}]},
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
        check_gathering_state(@offer)
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
    end    
#    p "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",offer.members.where("status = ?","confirmed").size.to_i
#    dd
  end
  
end
