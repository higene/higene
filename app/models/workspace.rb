class Workspace < ActiveRecord::Base
  has_many :members, dependent: :destroy
  has_many :namespaces, dependent: :destroy
  validates :name, presence: true
  validates :members, presence: true
  validate :unique_name
  validate :unique_owner
  after_create :create_default_namespace

  def owner
    if @_owner.nil?
      members.each do |member|
        if member.role == "owner"
          @_owner = member.user
          break
        end
      end
    end
    @_owner
  end

  private

  def unique_name
    return if name_was == name
    members.each do |current_member|
      if current_member.role == "owner"
        Member.where(user_id: current_member.user.id, role: "owner").each do |m|
          if m.workspace.name == name
            errors.add :name, "has existed"
            break
          end
        end
        break
      end
    end
  end

  def unique_owner
    owner_num = 0
    members.each do |current_member|
      if current_member.role == "owner"
        owner_num += 1
        if owner_num > 1
          errors.add :members, "Owner has existed."
          break
        end
      end
    end
  end

  def create_default_namespace
    Namespace.create(name: 'root', workspace: self)
  end
end
