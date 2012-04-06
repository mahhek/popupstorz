class CreateAvailabilityOptions < ActiveRecord::Migration
  def change
    create_table :availability_options do |t|
      t.string :name

      t.timestamps
    end
    AvailabilityOption.new(:name => "Day").save
    AvailabilityOption.new(:name => "Evening").save
    AvailabilityOption.new(:name => "Week").save
    AvailabilityOption.new(:name => "Weekend").save
  end
end
