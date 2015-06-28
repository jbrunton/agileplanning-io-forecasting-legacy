json.array!(@issues) do |issue|
  json.extract! issue, :id, :key, :summary, :dashboard_id, :started, :completed, :cycle_time
  json.url issue_url(issue, format: :json)
end
