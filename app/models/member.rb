class Member < ActiveRecord::Base
  belongs_to :user
  belongs_to :workspace
  validates :role, presence: true,
                   inclusion: { in: %w(owner editor viewer) }
end
