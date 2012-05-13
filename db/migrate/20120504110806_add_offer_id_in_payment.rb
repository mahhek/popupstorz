# -*- encoding : utf-8 -*-
class AddOfferIdInPayment < ActiveRecord::Migration
  def up
    add_column :payments, :offer_id, :integer
  end

  def down
    remove_column :payments, :offer_id
  end
end
