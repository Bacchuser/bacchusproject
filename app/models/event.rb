class Event < ActiveRecord::Base
  # Presenter from http://blog.jayfields.com/2007/03/rails-presenter-pattern.html
  include Authority::Abilities
  belongs_to :task, dependent: :destroy
  has_one :user_admin

  def public?
    self.is_public
  end

  def to_s
    inspect
  end
end
