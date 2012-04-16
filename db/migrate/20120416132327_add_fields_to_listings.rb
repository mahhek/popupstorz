class AddFieldsToListings < ActiveRecord::Migration
  def self.up
    add_column :items, :show_on_home, :boolean, :default => false
  end

  def self.down
    remove_column :items, :show_on_home
  end
end
