class AddColumnsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :verify_email, :string
    add_column :users, :mobile_phone, :integer
    add_column :users, :gender, :boolean
    add_column :users, :date_of_birth, :date
    add_column :users, :activity, :string
    add_column :users, :security_question, :string
    add_column :users, :security_answer, :string
    add_column :users, :city_country, :string
    add_column :users, :description, :string
    

  end


  def self.down
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :verify_email
    remove_column :users, :mobile_phone
    remove_column :users, :gender
    remove_column :users, :date_of_birth
    remove_column :users, :activity
    remove_column :users, :security_question
    remove_column :users, :security_answer
    remove_column :users, :city_country
    remove_column :users, :description

  end
end
