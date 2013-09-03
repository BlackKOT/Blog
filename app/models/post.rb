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

  def sql_clone_descendants_to(target_node)

    model = self.class.table_name
    tree_model = "#{self.class.model_name.downcase}_hierarchies"
    id_source_node = self.id

    self.class.transaction do
      sql_get_field_list = ActiveRecord::Base.connection().execute("
        SELECT replace(array_to_string(ARRAY(SELECT coalesce(column_default,column_name)
                                             FROM information_schema.columns
                                             WHERE table_name = '#{model}'
                                             ORDER BY ordinal_position
        ), ','),'old_node','id')")

      #TODO add in zzzzzzzz... Insert from elephant
      ActiveRecord::Base.connection.execute("
        INSERT INTO #{model}
          SELECT #{sql_get_field_list.first.values[0]} FROM #{model} t
          JOIN #{tree_model} h ON (t.id = h.descendant_id)
          WHERE h.ancestor_id = #{id_source_node} AND t.id != #{id_source_node};

        INSERT INTO #{tree_model}
          SELECT ancestor_id, id,generations + 1
          FROM #{tree_model},#{model}
          WHERE descendant_id = 31 and old_node IS NOT NULL
        UNION ALL SELECT id,id,0 from #{model} where old_node IS NOT NULL;

        UPDATE #{model} t
        SET parent_id = (CASE parent_id
                           WHEN #{id_source_node} THEN #{target_node.id}
                           ELSE (SELECT id FROM #{model} t2
                                 WHERE t2.old_node = t.parent_id)
                         END),
            old_node = NULL
        WHERE old_node IS NOT NULL;")
    end
  end

end