class CreateOfferMessages < ActiveRecord::Migration
  def change
    create_table :offer_messages do |t|
      t.integer :offer_id
      t.text :message
      t.integer :user_id
      t.string :msg_posted_as

      t.timestamps
    end
  end
end
