class Sequence
  include Cequel::Record

  key :workspace_id, :text, partition: true
  key :name, :text
  column :type, :text, index: true
  column :sequence, :text
  column :description, :text
  set :parents, :text
  set :children, :text
end
