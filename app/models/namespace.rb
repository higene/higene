class Namespace < ActiveRecord::Base
  belongs_to :workspace
  validates :name, presence: true,
                   uniqueness: { scope: :workspace }
  before_save :default_name_not_changed
  before_destroy :default_name_not_changed

  def self.default_name
    "root"
  end

  private

  def default_name_not_changed
    if name_was == self.class.default_name && present?
      errors.add(:name, "Can't change the default name.")
      false
    end
  end
end
