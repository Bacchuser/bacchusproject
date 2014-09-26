require 'forwardable'

class ListTask < ActiveRecord::Base
  belongs_to :task, dependent: :destroy

  extend Forwardable

  def_delegators :task, :label, :label=, :new?, :create_at

  def subclass?; true end

  def items
    if @items.nil?
      @items = ListTaskItem.where( { task_id: self.task_id } ).order( { sort_id: :asc, id: :desc } )
    end
    @items
  end
end
