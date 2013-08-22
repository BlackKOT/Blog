class AddParentIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :parent_id, :integer
    add_column :posts, :sort_order, :integer
  end
end
