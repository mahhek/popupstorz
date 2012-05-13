# -*- encoding : utf-8 -*-
class Offer < ActiveRecord::Base
  validate :rental_start_date, :presence => true
  validate :rental_end_date, :presence => true

  
  
  
  belongs_to :item
  belongs_to :user
  has_one :payment

  
  has_many :offer_messages, :dependent => :destroy
  accepts_nested_attributes_for :offer_messages, :allow_destroy => true

  before_save :set_owner_of_item

  def set_owner_of_item
    self.owner_id = self.item.user_id
  end


  def latest_message
    self.offer_messages.all.last
  end
end
