# -*- encoding : utf-8 -*-
class OfferMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :offer
end
