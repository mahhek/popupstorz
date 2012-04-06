class Offer < ActiveRecord::Base
validate :rental_start_date, :presence => true
  validate :rental_end_date, :presence => true
  validate :pickup_location, :presence => true
  belongs_to :item
  belongs_to :user
end
