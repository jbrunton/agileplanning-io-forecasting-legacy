json.array!(@dashboards) do |dashboard|
  json.extract! dashboard, :id, :domain, :board_id, :name
  json.url dashboard_url(dashboard, format: :json)
end
