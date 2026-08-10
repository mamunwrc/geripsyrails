class CreateUsrUsers < ActiveRecord::Migration
  def change
    create_table :usr_users do |t|
      t.string :last_name, limit: 64
      t.string :first_name, limit: 64
      t.string :middle_name, limit: 64
      t.string :title, limit: 16
      t.string :suffix, limit: 16
      t.string :initials, limit: 16
      t.string :ssn, limit: 16
      t.datetime :dob
      t.string :gender, limit: 16
      t.string :position
      t.string :address1, limit: 64
      t.string :address2, limit: 64
      t.string :city, limit: 64
      t.string :state, limit: 3
      t.string :zip, limit: 16
      t.string :home_phone, limit: 16
      t.string :work_phone, limit: 16
      t.string :fax, limit: 16
      t.string :cell, limit: 16
      t.string :pager, limit: 16
      t.string :alternate_phone, limit: 16
      t.string :email
      t.string :authorization_token, limit: 40
      t.string :login_name, limit: 128
      t.text :xml_data

      t.timestamps null: false
    end

    add_index :usr_users, :authorization_token
    add_index :usr_users, :login_name
  end
end
