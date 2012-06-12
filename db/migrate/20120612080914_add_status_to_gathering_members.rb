class AddStatusToGatheringMembers < ActiveRecord::Migration
  def change
    add_column :gathering_members, :status, :string
  end
end
