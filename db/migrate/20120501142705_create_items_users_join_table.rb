# -*- encoding : utf-8 -*-
class CreateItemsUsersJoinTable < ActiveRecord::Migration
  def up
    create_table :items_users, :id =>  false do |t|
      t.references :item, :user
    end
  end

  def down
        drop_table :items_users
  end
end
