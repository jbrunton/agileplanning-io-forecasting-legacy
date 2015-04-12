class Jira::RapidBoard
  attr_reader :id
  attr_reader :query

  def initialize(attrs)
    @id = attrs[:id]
    @query = attrs[:query]
  end
end