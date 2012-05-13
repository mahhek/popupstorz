# -*- encoding : utf-8 -*-
class AddColumnsInOffer < ActiveRecord::Migration
  def up
    add_column :offers, :preferred_location, :boolean, :default => false # false for owner's address and true for renter's preferred address.
    add_column :offers, :preferred_address, :string
  end

  def down
    remove_column :offers, :preferred_location
    remove_column :offers, :preferred_address
  end
end
