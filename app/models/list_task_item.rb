require 'forwardable'

class ListTaskItem < ActiveRecord::Base
  belongs_to :task, dependent: :destroy
  extend Forwardable
  def_delegators :task, :label, :label=, :new?, :create_at

  def is_subtask?; false end
  def has_subtask?; false  end

  def save_attributes(params)
    to_save = params.permit(:sort_id)
    raise to_save.inspect
  end
end
