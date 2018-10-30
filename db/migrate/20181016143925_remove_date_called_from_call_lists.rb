class RemoveDateCalledFromCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :call_lists, :date_called, :date
  end
end
