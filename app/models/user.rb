class User < ActiveRecord::Base
  attr_writer :login

  def login
    @login || username || email
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         authentication_keys: [:login]

  has_many :members
  validates :username, length: { in: 2..20 },
                       uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-zA-Z0-9_]+\Z/,
                                 message: "is alphanumerics and underscore only" }
  validates :email, uniqueness: { case_sensitive: false }

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
    else
      where(conditions.to_h).first
    end
  end
end
