class Offer < ActiveRecord::Base
  validate :rental_start_date, :presence => true
  validate :rental_end_date, :presence => true
  validate :pickup_location, :presence => true
  validate :price , :presence => true
  validate :price_unit  , :presence => true
  belongs_to :item
  belongs_to :user
  has_one :payment
  has_many :offer_messages, :dependent => :destroy



   def latest_message
    self.offer_messages.all.last
  end
end
