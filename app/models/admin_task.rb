class AdminTask < ActiveRecord::Base
  include Authority::Abilities

  belongs_to :task, dependent: :destroy

  def public?
    self.is_public
  end
end
