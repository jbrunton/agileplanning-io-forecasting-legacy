class Jira::Client
  MAX_RESULTS = 50

  def initialize(domain, params)
    @domain = domain
    @credentials = params.slice(:username, :password)
    @epic_link_id = get_field('Epic Link')['id']
    puts "*** @epic_link_id: #{@epic_link_id}"
  end

  def request(method, relative_url)
    uri = URI::join(@domain, relative_url)
    Rails.logger.info "issuing request to #{uri}"
    request = setup_request(uri)
    response = issue_request(uri, request)
    JSON.parse(response.body)
  end

  def search_issues(opts, &block)
    max_results = opts[:max_results] || MAX_RESULTS
    url = "rest/api/2/search?"
    url += "&expand=#{opts[:expand].join(',')}" if opts[:expand]
    url += "&jql=#{URI::escape(opts[:query])}" if opts[:query]
    url += "&startAt=#{opts[:startAt]}" if opts[:startAt]
    url += "&maxResults=#{max_results}"

    response = request(:get, url)

    issues = response['issues'].map do |raw_issue|
      Jira::IssueBuilder.new(raw_issue, @epic_link_id).build
    end

    startAt = response['startAt'] || 0
    progress = ((response['startAt'] + issues.length) * 100.0 / response['total']).to_i
    yield(progress) if block_given?
    if startAt + response['maxResults'] < response['total']
      startAt = startAt + response['maxResults']
      issues = issues + search_issues(opts.merge({:startAt => startAt}), &block)
    end

    issues
  end

  def get_rapid_boards
    url = "/rest/greenhopper/1.0/rapidviews/list"
    response = request(:get, url)
    response['views'].map do |raw_view|
      Jira::RapidBoardBuilder.new(raw_view).build
    end
  end

  def get_rapid_board(id)
    get_rapid_boards.find{ |board| board.id == id }
  end

  def get_fields
    url = "/rest/api/2/field"
    response = request(:get, url)
    response.map do |field|
      field.slice('id', 'name')
    end
  end

  def get_field(name)
    get_fields.find{ |field| field['name'] == name }
  end

  private
  def setup_request(uri)
    request = Net::HTTP::Get.new(uri)
    request.basic_auth @credentials['username'], @credentials['password']
    request
  end

  def issue_request(uri, request)
    Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
      http.request(request)
    end
  end
end
