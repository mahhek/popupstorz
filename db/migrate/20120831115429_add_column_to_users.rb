class AddColumnToUsers < ActiveRecord::Migration
  change_table :users do |t|
      t.change :confirmed_at, :datetime, :null => true
    end
  end