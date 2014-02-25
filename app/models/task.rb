class Task < ActiveRecord::Base
  include Authority::Abilities

  def visible?; is_visible end
end
