class AddCancellationPolicyFieldsToItems < ActiveRecord::Migration
  def change
    add_column :items,:cancellation_policy_flexible,:boolean
    add_column :items,:cancellation_policy_semi_flexible,:boolean
    
  end
end
