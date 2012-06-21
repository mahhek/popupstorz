class UpdateFbPagesInUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.change :fb_pages, :string, :null => true
    end
  end

  def self.down
    change_table :users do |t|
      t.change :fb_pages, :string, :null => true
    end
  end
end
