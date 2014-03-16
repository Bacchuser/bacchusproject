# Kind of interface for abilities, such as
#   * Admin
#   * View
#   * Organise
#   * Notify
#   * ...
module Role

  # Who is the user in that role ?
  def user_role
    raise "Not implemented"
  end

  # Which task is concerned by the role ?
  def task_role
    raise "Not implemented"
  end
end
