json.array!(@issues) do |issue|
  json.extract! issue, :id, :key, :summary, :project_id, :cycle_time
  json.url issue_url(issue, format: :json)
end
