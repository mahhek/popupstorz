class AddIsReadInNotifications < ActiveRecord::Migration
  def up
    add_column :notifications, :is_read, :boolean, :default => false
  end

  def down
    remove_column :notifications, :is_read
  end
end
