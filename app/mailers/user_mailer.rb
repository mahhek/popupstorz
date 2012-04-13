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
end
