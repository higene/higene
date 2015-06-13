class Workspace < ActiveRecord::Base
  has_many :members, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  before_destroy :destroy_data

  private

  def destroy_data
    [Sequence, Location].each do |klass|
      cmd = %(
        DELETE FROM #{klass.table_name}
               WHERE workspace_id = '#{id}'
      ).squish
      klass.connection.execute(cmd)
    end
  end
end
