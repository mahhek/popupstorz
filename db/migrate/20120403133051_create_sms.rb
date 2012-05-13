# -*- encoding : utf-8 -*-
class CreateSms < ActiveRecord::Migration
  def change
    create_table :sms do |t|

      t.timestamps
    end
  end
end
