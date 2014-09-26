require 'forwardable'

class SimpleTask < ActiveRecord::Base

  belongs_to :task, dependent: :destroy
  extend Forwardable

  def_delegators :task, :id, :label, :label=, :new?, :create_at

  def accessible;  [:start_at, :alert_at, :end_at] end
  def subclass?; true end

  def start_at=(date)
    write_attribute(:start_at, date.to_date) unless date.nil?
  end

  def alert_at=(date)
    write_attribute(:alert_at, date.to_date) unless date.nil?
  end

  def end_at=(date)
    write_attribute(:end_at, date.to_date) unless date.nil?
  end
end
