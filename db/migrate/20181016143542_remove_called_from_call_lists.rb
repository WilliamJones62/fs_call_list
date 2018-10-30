class RemoveCalledFromCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :call_lists, :called, :string
  end
end
