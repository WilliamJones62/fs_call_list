class CreateActiveCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :active_customers do |t|
      t.string :custcode
      t.string :rep
      t.string :shipto

      t.timestamps
    end
  end
end
