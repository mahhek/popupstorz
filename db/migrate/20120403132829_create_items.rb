class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :title
      t.integer :user_id
      t.integer :listing_type_id
      t.text :description
      t.string :address
      t.float :price
      t.string :price_unit
      t.string :time_for_unit_price
      t.datetime :availability_from
      t.datetime :availability_to
      t.string :time_period
      t.string :size
      t.string :type
      t.boolean :is_shareable, :default => true
      t.integer :maximum_members
      t.boolean :is_agree
      

      t.timestamps
    end
  end
end
