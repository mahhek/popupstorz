class CreateEmailSettings < ActiveRecord::Migration
  def change
    create_table :email_settings do |t|
      t.integer :user_id
      t.boolean :receive_person_message
      t.boolean :booking_request_update
      t.boolean :receive_booking_request
      t.boolean :upcoming_booking
      t.boolean :new_review
      t.boolean :review_required

      t.timestamps
    end
  end
end
