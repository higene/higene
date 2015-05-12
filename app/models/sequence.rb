class Sequence
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  fieed :description, type: String
  field :sequence, type: String
  field :taxid, type: Integer
  embeds_many :annotations
  embeds_many :expressions
  has_many :collections, as: :parents
  has_many :users, as: :owners
  belongs_to :subject
end

class Annotation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :source, type: String
  field :feature, type: String
  field :start, type: Integer
  field :end, type: Integer
  field :score, type: Float
  field :strand, type: String
  field :frame, type: Integer
  embeds_one :attribute
  embedded_in :sequence
end

class Attribute
  include Mongoid::Document
  include Mongoid::Timestamps

  field :gene_id, type: String
  field :transcript_id, type: String
  embedded_in :annotation
end

class Expression
  include Mongoid::Document
  include Mongoid::Timestamps

  field :condition, type: String
  field :source, type: String
  embeds_one :fpkm
  embeds_one :rpkm
  embedded_in :sequence
end

class Fpkm
  include Mongoid::Document
  include Mongoid::Timestamps

  field :value, type: Float
  belongs_to :expression
end

class Rpkm
  include Mongoid::Document
  include Mongoid::Timestamps

  field :value, type: Float
  belongs_to :expression
end
