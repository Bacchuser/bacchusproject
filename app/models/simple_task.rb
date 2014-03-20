class SimpleTask < ActiveRecord::Base
  belongs_to :task, dependent: :destroy

end
