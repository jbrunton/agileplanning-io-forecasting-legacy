json.array!(@wip_histories) do |wip_history|
  json.extract! wip_history, :id, :date
  json.url project_url(wip_history, format: :json)
end
