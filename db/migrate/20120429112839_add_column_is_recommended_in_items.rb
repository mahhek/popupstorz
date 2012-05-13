# -*- encoding : utf-8 -*-
class AddColumnIsRecommendedInItems < ActiveRecord::Migration
  def self.up
    add_column :items, :is_recommended, :boolean, :default => false
  end

  def self.down
    remove_column :items, :is_recommended
  end
end
