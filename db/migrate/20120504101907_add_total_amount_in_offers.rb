class AddTotalAmountInOffers < ActiveRecord::Migration
  def up
    add_column :offers, :total_amount, :float
  end

  def down
    remove_column :offers, :total_amount
  end
end
