class ChangeUserMessageInGathering < ActiveRecord::Migration
  def self.up
    change_table :gathering_members do |t|
      t.change :user_message, :text, :null => true
    end
  end

  def self.down
    change_table :gathering_members do |t|
      t.change :user_message, :text, :null => true
    end
  end
end
