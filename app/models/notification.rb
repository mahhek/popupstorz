# -*- encoding : utf-8 -*-
class Notification < ActiveRecord::Base
  belongs_to :user
  after_save :send_email_notification
  scope      :unread_notifications, where("is_read=false")

  def send_email_notification
    UserMailer.send_notification(self).deliver
  end
  
  def send_invitation_notification
    UserMailer.send_invitation_email(self).deliver
  end
end