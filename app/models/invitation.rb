class Invitation < ActiveRecord::Base
  belongs_to: task, dependent: :destroy

  def coming?; self.status == 2 end
  def invitation_pending?; self.status < 0 end
  def not_coming?; self.status == 0 end
  def not_sure?; self.status == 1 end

  def status_key
    case self.status
    when -1 then :invitation_pending
    when 0 then :not_coming
    when 1 then :not_sure
    when 2 then :coming
  end

  # Return the role the invitation is asking for.
  # We can ask for management of a task, or beeing a
  # guest of an event.
  def role
    if task.subclass_name == "event"
      return :guest
    else
      return :manager
  end
end