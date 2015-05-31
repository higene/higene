require 'workspace'
require 'alignment'

class Sequence
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :category, type: String
  field :sequence, type: String

  belongs_to :workspace, inverse_of: :children
  belongs_to :subject

  has_many :locations,
           class_name: "Location",
           inverse_of: :sequence
  has_and_belongs_to_many :children,
                          class_name: "Location",
                          inverse_of: :parents
  has_many :derivatives,
           class_name: "Location",
           inverse_of: :reference
end

class Location
  include Mongoid::Document

  field :source, type: String
  field :start, type: Integer
  field :end, type: Integer
  field :strand, type: Integer
  field :frame, type: Integer
  field :score, type: Float

  belongs_to :sequence,
             class_name: "Sequence",
             inverse_of: :locations
  has_and_belongs_to_many :parents,
                          class_name: "Sequence",
                          inverse_of: :children
  belongs_to :reference,
             class_name: "Sequence",
             inverse_of: :derivatives
end
