class RemoveDateCalledFromOverrideCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :override_call_lists, :date_called, :date
  end
end
