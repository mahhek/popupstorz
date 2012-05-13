# -*- encoding : utf-8 -*-
class ItemsHaveAndBelongsToManyAvailabilityOptions < ActiveRecord::Migration
  def up
    create_table :availability_options_items, :id =>  false do |t|
      t.references :availability_option, :item
    end
  end

  def down
    drop_table :availability_options_items
  end
end
