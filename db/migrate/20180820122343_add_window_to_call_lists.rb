class AddWindowToCallLists < ActiveRecord::Migration[5.1]
  def change
    add_column :call_lists, :window, :string
  end
end
