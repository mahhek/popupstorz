class AddFbFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :school, :string
    add_column :users, :works_at, :string
    add_column :users, :studied_at, :string
    add_column :users, :fb_pic_url, :string
    add_column :users, :fb_interests, :string
    add_column :users, :fb_friends_count, :integer    
    add_column :users, :fb_pages, :string
  end
end
