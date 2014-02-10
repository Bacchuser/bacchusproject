json.array!(@tasks) do |task|
  json.extract! task, :id, :created_at, :updated_at, :label, :is_visible
  json.url task_url(task, format: :json)
end
