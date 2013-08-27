class AddOldNodeToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :old_node, :integer
  end
end
