class RemoveNotesFromCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :call_lists, :notes, :string
  end
end
