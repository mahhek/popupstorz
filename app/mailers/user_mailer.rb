# -*- encoding : utf-8 -*-
class UserMailer < ActionMailer::Base
  default :from => "noreply@popupstorz.com"

  def send_notification(notification)
    @user = notification.user
    @notification = notification
    mail(:to => @user.email, :subject => "You have a new notification")
  end

  def send_invitation_email(invitation)
    @invitation = invitation
    mail(:to => invitation.email, :subject => "You are being requested by #{invitation.user.email} to join PopUpStorz")
  end
  
  def send_feedback(params)    
    @suggestion = params[:suggestion]
    @description = params[:description]
    @user = params[:user_name]
    @email = params[:email]    
    mail(:to => "[john.aghayan@gmail.com,aboukhater@gmail.com]", :subject => "A feedback is sent by #{params[:email]} for PopUpStorz")
  end
end
