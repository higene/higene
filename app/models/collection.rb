class Collection
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :category, type: String
  field :description, type: String
  has_one :user, as: :owner
  has_many :sequences, as: :children
  has_many :alignments, as: :children
end
