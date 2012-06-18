class AddCapturedToOffers < ActiveRecord::Migration
  def change
     add_column :offers, :is_captured, :boolean, :default => false
  end
end
