class Sequence
  include Cequel::Record
  attr_reader :locations

  key :workspace_id, :text, partition: true
  key :name, :text
  column :type, :text, index: true
  column :sequence, :text
  column :description, :text
  set :parents, :text
  set :children, :text

  def locations
    if @_locations.nil?
      @_locations = Location.where(workspace_id: workspace_id, target: name).to_a
    end
    @_locations
  end

  def parent_sequences
    if @_parent_sequences.nil?
      @_parent_sequences = []
      parents.each do |parent|
        @_parent_sequences << Sequence.find(workspace_id, parent)
      end
    end
    @_parent_sequences
  end

  def subsequences
    if @_subsequences.nil?
      @_subsequences = []
      children.each do |child|
        @_subsequences << Sequence.find(workspace_id, child)
      end
    end
    @_subsequences
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
