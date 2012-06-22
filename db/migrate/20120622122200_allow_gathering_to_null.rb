class AllowGatheringToNull < ActiveRecord::Migration
   def self.up
    change_table :offers do |t|
      t.change :gathering_deadline, :datetime, :null => true
    end
  end

  def self.down
    change_table :offers do |t|
      t.change :gathering_deadline, :datetime, :null => true
    end
  end
end
