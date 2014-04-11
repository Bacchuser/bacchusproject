require 'forwardable'

class SimpleTask < ActiveRecord::Base
  belongs_to :task, dependent: :destroy

  extend Forwardable

  def_delegators :task, :label, :label=, :new?, :create_at

  def subclass?; true end
end
