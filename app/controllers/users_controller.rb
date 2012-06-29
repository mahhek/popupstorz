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
    
    unless user.avatars.blank?
      user.avatars.destroy_all
    end
    
    unless user.notifications.blank?
      user.notifications.destroy_all
    end
    
    unless user.invitations.blank?
      user.invitations.destroy_all
    end
    
    unless user.services.blank?
      user.services.destroy_all
    end
    
    unless user.services.blank?
      user.services.destroy_all
    end
    
    unless user.items.blank?
      user.items.destroy_all
    end
    
    unless user.notifications.blank?
      user.notifications.destroy_all
    end
    
    unless user.offers.blank?
      user.offers.destroy_all
    end
    
    unless user.account.blank?
      user.account.destroy_all
    end
    
    unless user.email_setting.blank?
      user.email_setting.destroy_all
    end
    
    user.destroy
    
    
    flash[:notice] = "Account deleted successfully!"
    redirect_to "/users/sign_out"
  end
  
end