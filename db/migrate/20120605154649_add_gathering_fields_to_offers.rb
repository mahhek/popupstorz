class AddGatheringFieldsToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :persons_in_gathering, :integer
    add_column :offers, :gathering_rental_price, :float
    add_column :offers, :gathering_description, :text
    add_column :offers, :gathering_deadline, :datetime
  end
end