class ApplicationAuthorizer < Authority::Authorizer

  # Example call: `default(:creatable, current_user)`
  def self.default(able, user)
    Authority::logger.info  "ApplicationAuthorizer.self.default"
    user.god?
  end
end