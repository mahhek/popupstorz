class ChangeMobilePhoneDatatypeInUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.change :mobile_phone, :string
      t.change :description, :text
    end
  end

  def self.down
    #    change_table :users do |t|
    #      t.change :mobile_phone, :string
    #      t.change :description, :string
    #    end
  end

end
