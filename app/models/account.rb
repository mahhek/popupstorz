# -*- encoding : utf-8 -*-
class Account < ActiveRecord::Base
  belongs_to :user
end
