json.array!(@tests) do |test|
  json.extract! test, :id, :title, :description
  json.url test_url(test, format: :json)
end
