class Task < ActiveRecord::Base
  include Authority::Abilities
  belongs_to :task_tree, dependent: :destroy

  def visible?; is_visible end
end
