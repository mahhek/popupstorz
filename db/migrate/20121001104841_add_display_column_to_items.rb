class AddDisplayColumnToItems < ActiveRecord::Migration
  def change
    add_column :items, :display_on_home, :boolean, :default => true
  end
end
