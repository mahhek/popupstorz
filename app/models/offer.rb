class Offer < ActiveRecord::Base
  validate :rental_start_date, :presence => true
  validate :rental_end_date, :presence => true

  
  
  
  belongs_to :item
  belongs_to :user
  has_one :payment
  scope :my_offers, lambda { |user_id, item_id|
    { :conditions => ["user_id = ? and item_id = ?", user_id, item_id] }
  }
  has_many :offer_messages, :dependent => :destroy
  accepts_nested_attributes_for :offer_messages, :allow_destroy => true


  def latest_message
    self.offer_messages.all.last
  end
end
