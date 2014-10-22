require 'forwardable'

class ListTask < ActiveRecord::Base
  belongs_to :task

  extend Forwardable

  def_delegators :task, :label, :label=, :new?, :create_at

  def is_subtask?; true end
  def has_subtask?
    @items.count > 0
  end

  def items
    if @items.nil?
      @items = []
      self.task.children.each do |task|
        @items << task.subtask
      end
    end
    @items
  end

  def save_attributes(params)
    to_save = params.permit(:description)
    ListTask.transaction do
      self.description = to_save[:description]
      self.save!
    end
  end
end
