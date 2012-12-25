class AddPaymentFieldsToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :daily_price, :float
    add_column :offers, :cleaning_fee, :float
    add_column :offers, :sub_total, :float
    add_column :offers, :service_fee, :float
    add_column :offers, :total, :float
    add_column :offers, :current_currency, :string
    add_column :offers, :price_per_person, :float
  end
end
