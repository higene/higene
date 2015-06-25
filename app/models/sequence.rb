class Sequence
  include Cequel::Record
  attr_reader :locations

  key :workspace_id, :text, partition: true
  key :name, :text
  column :type, :text, index: true
  column :sequence, :text
  column :description, :text

  def locations
    Location.where(workspace_id: workspace_id, target: name).to_a
  end

  def parents
    if @_parents.nil?
      parent_names = Location.select(:parent)
                     .where(workspace_id: workspace_id, target: name)
                     .collect(&:parent)
                     .uniq
      if parent_names.first.nil?
        @_parents = []
      else
        @_parents = Sequence.where(workspace_id: workspace_id,
                                   name: parent_names).to_a
      end
    end
    @_parents
  end

  def children
    if @_children.nil?
      child_names = Location.select(:target)
                    .where(workspace_id: workspace_id, parent: name)
                    .collect(&:target)
                    .uniq
      if child_names.first.nil?
        @_children = []
      else
        @_children = Sequence.where(workspace_id: workspace_id,
                                    name: child_names).to_a
      end
    end
    @_children
  end

  def express_expressions
    if @_express_expressions.nil?
      @_express_expressions = Expression.where(workspace_id: workspace_id,
                                               target: name,
                                               source: "eXpress").to_a
    end
    @_express_expressions
  end
end
