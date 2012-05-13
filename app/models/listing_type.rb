# -*- encoding : utf-8 -*-
class ListingType < ActiveRecord::Base
  has_many :items
end
