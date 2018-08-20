class RemoveCallWindowFromCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :call_lists, :call_window, :integer
  end
end
