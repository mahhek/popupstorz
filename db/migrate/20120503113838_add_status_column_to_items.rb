# -*- encoding : utf-8 -*-
class AddStatusColumnToItems < ActiveRecord::Migration
  def change
    add_column :items, :item_status, :string
  end
end
