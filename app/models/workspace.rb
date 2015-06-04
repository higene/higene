require 'user'
# require 'sequence'
require 'alignment'

class Workspace
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String
  has_many :members
  # has_many :children, class_name: "Sequence"
  # has_many :children, class_name: "Alignment"
end

class Member
  include Mongoid::Document

  field :role, type: String
  belongs_to :user
  belongs_to :workspace
end
