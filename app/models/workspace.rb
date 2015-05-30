require 'user'
require 'sequence'
require 'alignment'

class Workspace
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String
  embeds_many :members
  has_many :children, class_name: "Sequence"
  has_many :children, class_name: "Alignment"
end

class Member
  include Mongoid::Document

  field :role, type: String
  has_one :user
  embedded_in :workspace
end
