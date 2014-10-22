require 'forwardable'

class SimpleTask < ActiveRecord::Base

  belongs_to :task, dependent: :destroy
  extend Forwardable

  def_delegators :task, :label, :label=, :new?, :create_at

  def is_subtask?; true end
  def has_subtask?; false end

  def start_at=(date)
    write_attribute(:start_at, date.to_date) unless date.nil?
  end

  def alert_at=(date)
    write_attribute(:alert_at, date.to_date) unless date.nil?
  end

  def end_at=(date)
    write_attribute(:end_at, date.to_date) unless date.nil?
  end


  def save_attributes(params)
    to_save = params.permit(:start_at, :alert_at, :end_at)
    SimpleTask.transaction do
      self.start_at = to_save[:start_at]
      self.alert_at = to_save[:alert_at]
      self.end_at = to_save[:end_at]
      self.save!
    end
  end
end
