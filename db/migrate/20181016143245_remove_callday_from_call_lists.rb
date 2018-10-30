class RemoveCalldayFromCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :call_lists, :callday, :string
  end
end
