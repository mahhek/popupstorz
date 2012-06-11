class CreateGatheringMembers < ActiveRecord::Migration
  def change
    create_table :gathering_members do |t|
      
      t.integer :offer_id
      t.integer :user_id
      
      t.timestamps
    end
  end
end
