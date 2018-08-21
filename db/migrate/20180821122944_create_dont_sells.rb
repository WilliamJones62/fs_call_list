class CreateDontSells < ActiveRecord::Migration[5.1]
  def change
    create_table :dont_sells do |t|
      t.string :customer
      t.string :part
      t.date :dontcalls_start
      t.date :dontcalls_end

      t.timestamps
    end
  end
end
