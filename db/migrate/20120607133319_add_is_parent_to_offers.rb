class AddIsParentToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :parent_id, :integer
  end
end
