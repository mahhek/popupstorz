# -*- encoding : utf-8 -*-
class AddCancellationDateInOffers < ActiveRecord::Migration
  def up
    add_column :offers, :cancellation_date, :datetime
  end

  def down
    remove_column :offers, :cancellation_date
  end
end
