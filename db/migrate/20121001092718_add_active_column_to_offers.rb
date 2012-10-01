class AddActiveColumnToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :is_active, :boolean, :default => true
  end
end
