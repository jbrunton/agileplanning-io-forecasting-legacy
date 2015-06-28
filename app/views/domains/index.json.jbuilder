json.array!(@domains) do |domain|
  json.extract! domain, :id, :name, :domain, :last_synced
  json.url domain_url(domain, format: :json)
end
