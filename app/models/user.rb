# Useless for now. Was an attempt to deploy Authority gem.
# FIXEME dead code
class User < ActiveRecord::Base
  include Authority::UserAbilities
  validates :username,
              :uniqueness => { :case_sensitive => false }

  # Track the modifications of the user
  #    http://ruby-journal.com/how-to-track-changes-with-after-callbacks-in-rails-3-or-newer/
  around_update :refresh_updated_at

  def god?; false end

  def register?; false end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["username = :value OR lower(email) = lower(:value)", { :value => login } ]).first
    else
      where(conditions).first
    end
  end

  private

  def refresh_updated_at
    # To avoid infinite recursion, we need to change only
    #   if the update_at field is not updated
    is_changed = (not self.updated_at_changed?) and self.changed?

    yield # perform the update

    if is_changed
      self.update_at = Time.now
      self.save
    end
  end
end