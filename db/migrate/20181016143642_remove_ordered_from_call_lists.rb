class RemoveOrderedFromCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :call_lists, :ordered, :string
  end
end
