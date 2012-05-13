# -*- encoding : utf-8 -*-
class Ratings < ActiveRecord::Migration
   def self.up
    create_table "ratings", :force => true do |t|
      t.column :communication_rating, :integer, :default => 0
      t.column :accuracy_rating, :integer, :default => 0
      t.column :location_rating, :integer, :default => 0
      t.column :seriousness_rating, :integer, :default => 0
      t.column :commodities_rating, :integer, :default => 0
      t.column :value_rating, :integer, :default => 0
      t.column :rateable_type, :string, :limit => 50,:default => "", :null => false
      t.column :rateable_id, :integer, :default => 0, :null => false
      t.column :user_id, :integer, :default => 0, :null => false
      t.column :created_at, :datetime, :null => false
    end

    add_index "ratings", ["user_id"], :name => "fk_ratings_user"
  end

  def self.down
    drop_table :ratings
  end 
end
