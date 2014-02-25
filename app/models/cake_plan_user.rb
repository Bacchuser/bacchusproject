class CakePlanUser < ActiveRecord::Base
  include Authority::UserAbilities

  belongs_to :user, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  def register?; id? end


end
