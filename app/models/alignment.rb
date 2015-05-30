require 'workspace'
require 'sequence'

class Alignment
  include Mongoid::Document

  field :source, type: String
  field :align_length, type: Integer
  field :pct_identity, type: Float
  field :mismatches, type: Integer
  field :gap_opens, type: Integer
  field :evalue, type: Float
  field :bit_score, type: Float
  field :gaps, type: Integer
  field :identical, type: Integer
  field :positive, type: Integer
  field :pct_positive, type: Float
  embeds_many :subjects
  belongs_to :workspace, inverse_of: :children
end

class Subject
  include Mongoid::Document

  field :strand, type: String
  field :frame, type: String
  field :start, type: Integer
  field :end, type: Integer
  field :coverage, type: Float
  has_one :sequence
end
