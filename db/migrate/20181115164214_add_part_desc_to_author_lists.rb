class AddPartDescToAuthorLists < ActiveRecord::Migration[5.1]
  def change
    add_column :author_lists, :part_desc, :string
  end
end
