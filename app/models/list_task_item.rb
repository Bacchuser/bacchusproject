require 'forwardable'

class ListTaskItem < ActiveRecord::Base
  belongs_to :task, dependent: :destroy
  extend Forwardable
  def_delegators :task, :label, :label=, :new?, :create_at

  def is_subtask?; false end
  def has_subtask?; false  end

  def save_attributes(params)
    to_save = params.permit(:description)
    ListTaskItem.transaction do
      self.description = to_save[:description]
      self.save!
    end
  end


end
