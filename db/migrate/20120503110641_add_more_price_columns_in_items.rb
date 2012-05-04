class AddMorePriceColumnsInItems < ActiveRecord::Migration
  def up
    add_column :items, :price_per_week, :float
    add_column :items, :price_per_month, :float
  end

  def down
    remove_column :items, :price_per_week
    remove_column :items, :price_per_month
  end
end
