class ListTaskItem < ActiveRecord::Base
  belongs_to :list_task, dependent: :destroy
  belongs_to :task, dependent: :destroy
end
