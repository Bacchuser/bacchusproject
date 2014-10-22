require 'forwardable'

class ListTask < ActiveRecord::Base
  belongs_to :task, dependent: :destroy

  extend Forwardable

  def_delegators :task, :label, :label=, :new?, :create_at

  def is_subtask?; true end
  def has_subtask?
    @items.count > 0
  end

  def items
    if @items.nil?
      @items = ListTaskItem.where( { task_id: self.task_id } ).order( { sort_id: :asc, id: :desc } )
    end
    @items
  end

  def save_attributes(params)
    to_save = params.permit()
    raise to_save.inspect
  end
end
