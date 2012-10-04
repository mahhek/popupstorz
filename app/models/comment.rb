# -*- encoding : utf-8 -*-
class Comment < ActiveRecord::Base
  belongs_to :user
  validates :comment, :presence => true
end
