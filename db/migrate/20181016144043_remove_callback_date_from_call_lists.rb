class RemoveCallbackDateFromCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :call_lists, :callback_date, :date
  end
end
