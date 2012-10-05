class AddColumnsToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :is_active, :boolean, :default => true
    add_column :payments, :cancelled_at, :datetime
  end
end
