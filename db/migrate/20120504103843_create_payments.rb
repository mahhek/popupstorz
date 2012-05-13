# -*- encoding : utf-8 -*-
class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :seller_id
      t.integer :renter_id
      t.float :amount
      t.float :rentareto_fee
      t.float :seller_amount
      t.string :email
      t.string :stripe_customer_token
      t.string :stripe_card_token
      t.string :transaction_number
      t.string :status

      t.timestamps
    end
  end
end
