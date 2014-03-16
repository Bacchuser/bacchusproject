# Used to be the root of all the differents tasks.
# A task is strongly linked with an element of a task_tree,
# and we can even see a Task as a DECORATOR of a Task_tree.
#
# The goal of task tree is to manage a skeleton, and Task is
# flesh, and Subclasses of Task are skin.
class Task < ActiveRecord::Base
  include Authority::Abilities
  belongs_to :task_tree, dependent: :destroy

  def visible?; is_visible end
end
