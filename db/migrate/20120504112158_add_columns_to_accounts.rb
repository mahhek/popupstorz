class AddColumnsToAccounts < ActiveRecord::Migration
  def up
    add_column :accounts, :stripe_card_token, :string
    add_column :accounts, :user_id, :integer
    add_column :accounts, :email, :string
    add_column :accounts, :plan_id, :string

  end
end
