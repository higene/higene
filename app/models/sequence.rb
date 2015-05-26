require 'workspace'
require 'alignment'

class Sequence
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :feature, type: String
  field :sequence, type: String
  field :taxid, type: Integer

  embeds_many :locations
  embeds_many :resoueces
  belongs_to :workspace
  belongs_to :subject
  belongs_to :location
end

class Location
  include Mongoid::Document

  field :source, type: String
  field :start, type: Integer
  field :end, type: Integer
  field :strand, type: Integer
  field :frame, type: Integer
  field :score, type: Float

  has_one :sequence, as: :parent
  embedded_in :sequence
end

class Resource
  include Mongoid::Document

  field :name
  field :link
end
