class RemoveDateOrderedFromOverrideCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :override_call_lists, :date_ordered, :date
  end
end
