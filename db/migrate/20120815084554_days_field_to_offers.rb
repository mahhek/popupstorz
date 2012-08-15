class DaysFieldToOffers < ActiveRecord::Migration
  def up
    add_column :offers,:total_days,:integer
  end

  def down
    remove_column :items,:availablities_daytime
  end
end
