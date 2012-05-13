# -*- encoding : utf-8 -*-
# Include hook code here
require 'acts_as_rateable'
ActiveRecord::Base.send(:include, Juixe::Acts::Rateable)
