class AddMessageToGatheringMembers < ActiveRecord::Migration
  def change
     add_column :gathering_members, :user_message, :text
  end
end
