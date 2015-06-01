require 'workspace'
require 'alignment'

class Sequence
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :type, type: String
  field :sequence, type: String

  belongs_to :workspace, inverse_of: :children
  belongs_to :subject

  has_many :locations,
           class_name: "Location",
           inverse_of: :sequence
  has_many :children,
           class_name: "Location",
           inverse_of: :parent
  has_many :derivatives,
           class_name: "Location",
           inverse_of: :reference
end

class Location
  include Mongoid::Document

  field :source, type: String
  field :start, type: Integer
  field :end, type: Integer
  field :score, type: Float
  field :strand, type: String
  field :phase, type: Integer

  belongs_to :sequence,
             class_name: "Sequence",
             inverse_of: :locations
  belongs_to :parent,
             class_name: "Sequence",
             inverse_of: :children
  belongs_to :reference,
             class_name: "Sequence",
             inverse_of: :derivatives
end
