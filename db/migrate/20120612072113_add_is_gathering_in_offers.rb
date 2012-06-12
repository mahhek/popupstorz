class AddIsGatheringInOffers < ActiveRecord::Migration
  def up
    add_column :offers, :is_gathering, :boolean
  end

  def down
    remove_column :offers, :is_gathering
  end
end
