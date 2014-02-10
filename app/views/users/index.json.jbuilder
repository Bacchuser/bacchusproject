json.array!(@users) do |user|
  json.extract! user, :id, :created_at, :updated_at, :last_ip, :email, :is_email_valid
  json.url user_url(user, format: :json)
end
