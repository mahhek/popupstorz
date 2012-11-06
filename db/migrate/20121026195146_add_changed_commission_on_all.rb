class AddChangedCommissionOnAll < ActiveRecord::Migration
  def up
    add_column :items, :commission_changed_on_all, :boolean, :default => false
  end

  def down
    remove_column :items, :commission_changed_on_all
  end
end
