class Post < ActiveRecord::Base

  attr_accessible :body, :title, :user_id, :parent_id, :old_node

  acts_as_tree :dependent => :delete_all

  belongs_to :user

  validates :body, :length => { :in => 1..254 }, :allow_blank => false
  validates :title, :user_id, :presence => true

  def to_param
    "#{id}-#{title.parameterize}"
  end

  def clone_descendants_to(target_node)
    model = self.class
    model.transaction do
      self.descendants.each do |node|
        parent_id = (node.parent_id == self.id) ? target_node.id : model.where(:old_node => node.parent_id).first.id
        node.dup.update_attributes(:old_node => node.id, :parent_id => parent_id)
      end
      model.update_all({:old_node => nil}, model.arel_table[:old_node].not_eq(nil))
    end
  end

end