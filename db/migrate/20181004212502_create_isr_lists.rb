class CreateIsrLists < ActiveRecord::Migration[5.1]
  def change
    create_table :isr_lists do |t|
      t.string :name

      t.timestamps
    end
  end
end
