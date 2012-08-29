# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  
  def add_comment
    @comment = Comment.new(params[:comment])
    @comment.user=current_user
    @user = User.find(params[:id])
    if @comment.save
      flash[:notice] = "Comment Added"
      @user.comments << @comment
      redirect_to profile_path(current_user)
    else
      flash[:error] = "Not saved"
      render :show
    end

  end

  def show
    @user = User.find_by_id(params[:id])
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
  
  def send_invitation
    @invitation = Invitation.new
    @invitation.user = current_user
    @invitation.email = params[:email]
    @invitation.token =  (Digest::MD5.hexdigest "#{ActiveSupport::SecureRandom.hex(10)}-#{DateTime.now.to_s}")
    @invitation.save
    UserMailer.send_invitation_email(@invitation).deliver
    flash[:notice] = "Invitations have been sent successfully."
    redirect_to "/invitation"
  end
  
  def delete_account
    user = current_user
    user.update_attribute("is_active",false)
#    unless user.avatars.blank?
#      user.avatars.destroy_all
#    end
#    
#    unless user.notifications.blank?
#      user.notifications.destroy_all
#    end
#    
#    unless user.invitations.blank?
#      user.invitations.destroy_all
#    end
#    
#    unless user.services.blank?
#      user.services.destroy_all
#    end
#    
#    unless user.services.blank?
#      user.services.destroy_all
#    end
#    
#    unless user.items.blank?
#      user.items.destroy_all
#    end
#    
#    unless user.notifications.blank?
#      user.notifications.destroy_all
#    end
#    
#    unless user.offers.blank?
#      user.offers.destroy_all
#    end
#    
#    unless user.account.blank?
#      user.account.destroy_all
#    end
#    
#    unless user.email_setting.blank?
#      user.email_setting.destroy_all
#    end
#    
#    user.destroy
    flash[:notice] = "Account deleted successfully!"
    redirect_to "/users/sign_out"
  end
  
end