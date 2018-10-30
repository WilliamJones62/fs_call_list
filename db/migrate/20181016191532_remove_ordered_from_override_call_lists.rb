class RemoveOrderedFromOverrideCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :override_call_lists, :ordered, :string
  end
end
