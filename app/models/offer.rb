# -*- encoding : utf-8 -*-
class Offer < ActiveRecord::Base
  acts_as_commentable
  
  validate :rental_start_date, :presence => true
  validate :rental_end_date, :presence => true
  
  belongs_to :item
  belongs_to :user
  has_one :payment

  
  has_many :offer_messages, :dependent => :destroy
  accepts_nested_attributes_for :offer_messages, :allow_destroy => true
  
  has_and_belongs_to_many :members, :class_name => 'User', :join_table => 'gathering_members', :association_foreign_key => 'user_id'

  before_save :set_owner_of_item

  def set_owner_of_item
    self.owner_id = self.item.user_id
  end


  def latest_message
    self.offer_messages.all.last
  end
end
