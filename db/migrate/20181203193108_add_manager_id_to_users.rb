class AddManagerIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :manager_id, :string
  end
end
