class CreateCallDays < ActiveRecord::Migration[5.1]
  def change
    create_table :call_days do |t|
      t.integer :call_list_id
      t.string :callday
      t.string :notes
      t.string :isr
      t.string :called
      t.date :date_called
      t.string :ordered
      t.date :date_ordered
      t.string :callback
      t.date :callback_date
      t.string :window

      t.timestamps
    end
  end
end
