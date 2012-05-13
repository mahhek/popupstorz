class AddWantToBargainInOffers < ActiveRecord::Migration
  
  def up
    add_column :offers, :want_to_bargain, :boolean, :default => false
  end

  def down
    remove_column :offers, :want_to_bargain
  end
  
end
