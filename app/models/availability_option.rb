# -*- encoding : utf-8 -*-
class AvailabilityOption < ActiveRecord::Base
  has_and_belongs_to_many :items
end
