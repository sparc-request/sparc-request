# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class CreateContactForms < ActiveRecord::Migration
  def change
    create_table :contact_forms do |t|
      t.string :subject
      t.string :email
      t.text :message

      t.timestamps null: false
    end
  end
end
