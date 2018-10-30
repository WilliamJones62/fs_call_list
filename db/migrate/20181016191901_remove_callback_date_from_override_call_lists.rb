class RemoveCallbackDateFromOverrideCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :override_call_lists, :callback_date, :date
  end
end
