class CreateOnSpecials < ActiveRecord::Migration[5.1]
  def change
    create_table :on_specials do |t|
      t.string :customer
      t.string :part
      t.date :onspecials_start
      t.date :onspecials_end

      t.timestamps
    end
  end
end
