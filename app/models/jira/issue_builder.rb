class Jira::IssueBuilder
  def initialize(json)
    @json = json
  end

  def build
    attrs = {
        :key => key,
        :summary => summary
    }

    Issue.new(attrs)
  end

private
  def key
    @json['key']
  end

  def summary
    @json['fields']['summary']
  end
end