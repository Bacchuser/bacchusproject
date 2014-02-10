class Task < ActiveRecord::Base
  include Authority::Abilities

end
