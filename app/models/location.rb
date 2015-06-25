class Location
  include Cequel::Record

  key :workspace_id, :text, partition: true
  key :reference, :text
  key :type, :text
  key :loc_start, :int
  key :loc_end, :int
  key :source, :text
  column :target, :text, index: true
  column :parent, :text, index: true
  column :score, :float
  column :strand, :text
  column :phase, :int
end
