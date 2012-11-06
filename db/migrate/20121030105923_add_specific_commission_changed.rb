class AddSpecificCommissionChanged < ActiveRecord::Migration
  def up
    remove_column :items, :commission_changed_on_all
    add_column :items, :specific_commission_changed, :boolean, :default => false
  end

  def down
    remove_column :items, :specific_commission_changed
  end
end
