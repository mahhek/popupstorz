class AddUserIdInAvatars < ActiveRecord::Migration
  def up
    add_column :avatars, :user_id, :integer
  end

  def down
    remove_column :avatars, :user_id
  end
end
