# -*- encoding : utf-8 -*-
class AddColumnsInItems < ActiveRecord::Migration
  def self.up
    add_column :items, :cleaning_fee, :float
    add_column :items, :deposit, :float
  end

  def self.down
    remove_column :cleaning_fee, :deposit
    remove_column :items, :deposit
  end
end
