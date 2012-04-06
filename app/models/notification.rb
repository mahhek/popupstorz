class Notification < ActiveRecord::Base
 belongs_to :user
  after_save :send_email_notification

  def send_email_notification
    UserMailer.send_notification(self).deliver
  end
end
