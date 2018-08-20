class AddCallWindowToCallLists < ActiveRecord::Migration[5.1]
  def change
    add_column :call_lists, :call_window, :integer
  end
end
