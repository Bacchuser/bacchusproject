class AdminTask < ActiveRecord::Base
  # Presenter from http://blog.jayfields.com/2007/03/rails-presenter-pattern.html
  include Authority::Abilities
  belongs_to :task, dependent: :destroy

  def public?
    self.is_public
  end
end
