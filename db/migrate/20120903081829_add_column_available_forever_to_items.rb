class AddColumnAvailableForeverToItems < ActiveRecord::Migration
  def change
    add_column :items,:available_forever,:boolean
  end
end
