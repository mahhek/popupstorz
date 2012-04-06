class CreateListingTypes < ActiveRecord::Migration
  def change
    create_table :listing_types do |t|
      t.string :name

      t.timestamps
    end
    ListingType.new(:name => "Shop").save
    ListingType.new(:name => "Appartment").save
    ListingType.new(:name => "Shop in shop").save
    ListingType.new(:name => "Warehouse").save
    ListingType.new(:name => "Office").save
    ListingType.new(:name => "Restaurant/Bar").save
    ListingType.new(:name => "Hotel").save
  end
end
