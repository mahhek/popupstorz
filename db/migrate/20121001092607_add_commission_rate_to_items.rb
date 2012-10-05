class AddCommissionRateToItems < ActiveRecord::Migration
  def change
    add_column :items, :guest_commission_rate, :integer, :default => 10
    add_column :items, :owner_commission_rate, :integer, :default => 10
  end
end
