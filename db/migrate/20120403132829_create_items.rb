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
      t.string :size_unit
      t.string :type
      t.boolean :is_shareable, :default => true
      t.integer :maximum_members
      t.boolean :is_agree

      t.string :neighbourhood
      t.string :country_code
      t.string :county
      t.string :region
      t.string :city
      t.string :zipcode
      t.string :street
      t.decimal :latitude, :precision => 15, :scale => 10
      t.decimal :longitude, :precision => 15, :scale => 10
      t.string :street_name
      t.string :street_number
      t.references :locatable, :polymorphic => true

      t.timestamps
    end
  end
end
