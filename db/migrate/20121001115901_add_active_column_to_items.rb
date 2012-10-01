class AddActiveColumnToItems < ActiveRecord::Migration
  def change
    add_column :items, :is_active, :boolean, :default => true
  end
end
