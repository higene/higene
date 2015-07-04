class Expression
  include Cequel::Record

  key :workspace_id, :text, partition: true
  key :target, :text
  key :source, :text
  key :condition, :text
  column :fpkm, :float
  column :tot_counts, :int
  column :uniq_counts, :int
  column :eff_counts, :float
end
