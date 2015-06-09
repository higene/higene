class Workspace < ActiveRecord::Base
  has_many :members, dependent: :destroy
  validates :name, presence: true, uniqueness: true
end
