class AddOwnerIdInOffers < ActiveRecord::Migration
  def up
    add_column :offers, :owner_id, :integer
  end

  def down
    remove_column :offers, :owner_id
  end
end
