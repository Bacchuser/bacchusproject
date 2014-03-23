
# +---------------------------------+
# | Event instance                  |      An instance of event task is
# |---------------------------------|      particular : It has a reference
# |                                 |      on the task node. And the task node
# |                                 |      has a reference on the event. All the
# | +---------------------------+   |      task node of the childs will have this
# | | Task (Node in the tree)  <--------+  link. Like this, we can query only
# | |---------------------------|   |   |  nodes in the event_id given.
# | |Label : String             |   |   |
# | |Tree Stuff  ...            |   |   |
# | |event_id : Integer +-------------+ |
# | +---------------------------+   | | |
# |                                 | | |
# |                                 | | |
# | +---------------------------+   | | |
# | | Event - General infos    <------+ |
# | |---------------------------|   |   |
# | |Desctiption : String       |   |   |
# | |Start_at : Date            |   |   |
# | |End_at : Date              |   |   |
# | |task_id : Integer +----------------+
# | +---------------------------+   |
# |                                 |
# +---------------------------------+
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
