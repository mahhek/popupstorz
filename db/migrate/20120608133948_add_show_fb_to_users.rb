class AddShowFbToUsers < ActiveRecord::Migration
  def change
    add_column :users, :show_fb_info, :boolean
  end
end
