# -*- encoding : utf-8 -*-
class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.datetime :rental_start_date
      t.datetime :rental_end_date
      t.string :pickup_location
      t.float :willingness_to_pay
      t.integer :required_response_by_owner_before
      t.string :additional_message
      t.string :status
      t.integer :item_id
      t.integer :user_id
      t.timestamps
    end
  end
end
