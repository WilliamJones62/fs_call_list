class RemoveDateOrderedFromCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :call_lists, :date_ordered, :date
  end
end
