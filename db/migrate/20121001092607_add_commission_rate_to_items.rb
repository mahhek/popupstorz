class AddCommissionRateToItems < ActiveRecord::Migration
  def change
    add_column :items, :commission_rate, :integer, :default => 10
  end
end
