class RemoveIsrFromOverrideCallLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :override_call_lists, :isr, :string
  end
end
