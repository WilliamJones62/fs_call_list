class RemoveNotesFromOverrideCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :override_call_lists, :notes, :string
  end
end
