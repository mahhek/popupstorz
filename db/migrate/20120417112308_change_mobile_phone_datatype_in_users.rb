class ChangeMobilePhoneDatatypeInUsers < ActiveRecord::Migration
def self.up
    change_table :users do |t|
      t.change :mobile_phone, :string
    end
  end

end
