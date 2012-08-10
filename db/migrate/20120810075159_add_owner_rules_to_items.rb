class AddOwnerRulesToItems < ActiveRecord::Migration
  def change
    add_column :items, :owner_rule, :string
  end
end
