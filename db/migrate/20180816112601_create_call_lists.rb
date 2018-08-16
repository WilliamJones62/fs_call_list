class CreateCallLists < ActiveRecord::Migration[5.1]
  def change
    create_table :call_lists do |t|
      t.string :custcode
      t.string :custname
      t.string :contact_method
      t.string :callday
      t.text :notes
      t.string :contact
      t.string :phone
      t.string :email
      t.string :selling
      t.string :main_phone
      t.string :website
      t.string :rep
      t.string :isr
      t.string :called
      t.date :date_called
      t.string :ordered
      t.date :date_ordered
      t.string :callback
      t.date :callback_date

      t.timestamps
    end
  end
end
