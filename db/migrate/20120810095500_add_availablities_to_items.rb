class AddAvailablitiesToItems < ActiveRecord::Migration
  def change
    add_column :items,:availablities_daytime,:boolean
    add_column :items,:availablities_evenings,:boolean
    add_column :items,:availablities_monday,:boolean
    add_column :items,:availablities_tuesday,:boolean
    add_column :items,:availablities_wednesday,:boolean
    add_column :items,:availablities_thursday,:boolean
    add_column :items,:availablities_friday,:boolean
    add_column :items,:availablities_saturday,:boolean
    add_column :items,:availablities_sunday,:boolean
  end
end
