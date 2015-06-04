class Sequence
  include Cequel::Record

  key :workspace_id, :text
  key :name, :text
  column :type, :text, index: true
  column :sequence, :text
  set :parents, :text
  set :children, :text
end

class Location
  include Cequel::Record

  key :id, :uuid, auto: true
  key :workspace_id, :text
  column :source, :text
  column :reference, :text, index: true
  column :query, :text, index: true
  column :start, :int
  column :end, :int
  column :score, :float
  column :strand, :text
  column :phase, :int
end
