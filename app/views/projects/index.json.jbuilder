json.array!(@projects) do |project|
  json.extract! project, :id, :domain, :board_id, :name
  json.url project_url(project, format: :json)
end
