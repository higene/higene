require 'user'
require 'sequence'
require 'alignment'

class Workspace
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String
  embeds_many :members
  has_many :sequences, as: :children
  has_many :alignments, as: :children
end

class Member
  include Mongoid::Document

  field :role, type: String
  has_one :user
  embedded_in :workspace
end
