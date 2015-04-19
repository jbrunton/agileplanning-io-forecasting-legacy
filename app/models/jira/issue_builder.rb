class Jira::IssueBuilder
  def initialize(json)
    @json = json
  end

  def build
    attrs = {
        :key => key,
        :summary => summary,
        :issue_type => issue_type
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

  def issue_type
    @json['fields']['issuetype']['name']
  end
end