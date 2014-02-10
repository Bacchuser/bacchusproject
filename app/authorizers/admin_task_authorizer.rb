class AdminTaskAuthorizer < ApplicationAuthorizer

  def readable_by(user)
    resource.public?
  end
end