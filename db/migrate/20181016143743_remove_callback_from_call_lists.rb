class RemoveCallbackFromCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :call_lists, :callback, :string
  end
end
