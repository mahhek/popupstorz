class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :avatars, :dependent => :destroy
  accepts_nested_attributes_for :avatars, :allow_destroy => true
#  belongs_to :country

  devise :database_authenticatable, :registerable, :confirmable,
    :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name,
    :verify_email, :mobile_phone, :gender, :date_of_birth, :activity, :security_question,
    :security_answer, :city_country, :description, :avatars_attributes, :address1, :address2,
    :zip_code, :city, :country, :neighbourhood
  
  acts_as_messageable :table_name => "messages",
    :required => [:topic, :body],
    :class_name => "ActsAsMessageable::Message"
  
  validates :email, :presence => true
  validates :verify_email, :presence => true
  validates :mobile_phone, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :security_question, :presence => true
  validates :security_answer, :presence => true
  validates :date_of_birth, :presence => true


  has_many :services
  has_many :items
  has_many :notifications
  has_many :offers
  has_one  :account
  

  def popup_storz_display_name
    return"#{self.first_name[0..6]} #{self.last_name[0..0].capitalize} ." if self.last_name
    self.first_name
  end
  #after_save :send_user_notification
  #  after_save :create_account_just_activated_user

  #def send_user_notification
  #    if self.confirmed_at_changed? and self.email?
  #      Notification.new(:user_id => self.id, :notification_type =>"Welcome", :description => "You have successfully signed up, thanks!").save
  #    end
  #  end

  #  def create_account_just_activated_user
  #    if self.confirmed_at_changed? and self.email?
  #      Account.new(:email => self.email, :user_id => self.id).save if self.account.blank?
  #    end
  #  end

  def popupstorz_display_name
    "#{self.first_name[0..6]} #{self.last_name[0..0].capitalize}" if self.last_name
  end

  def update_with_password(params={})
    current_password = params.delete(:current_password)
    check_password = true
    if params[:password].blank?
      params.delete(:password)
      if params[:password_confirmation].blank?
        params.delete(:password_confirmation)
        check_password = false
      end
    end
    result = if valid_password?(current_password) || !check_password
      update_attributes(params)
    else
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      self.attributes = params
      false
    end
    clean_up_passwords
    result
  end


  
end
