class RemoveIsrFromCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :call_lists, :isr, :string
  end
end
