class RemoveWindowFromCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :call_lists, :window, :string
  end
end
