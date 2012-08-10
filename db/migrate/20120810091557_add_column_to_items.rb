class AddColumnToItems < ActiveRecord::Migration
  def change
    add_column :items, :owner_rules, :text
  end
end
