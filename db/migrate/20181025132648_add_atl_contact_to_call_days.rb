class AddAtlContactToCallDays < ActiveRecord::Migration[5.1]
  def change
    add_column :call_days, :alt_contact, :string
  end
end
