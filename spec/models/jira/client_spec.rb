require 'rails_helper'

RSpec::Matchers.define :be_equivalent_to do |expected|
  match do |actual|
    actual_attrs = actual.attributes.except(['id', 'created_at', 'updated_at'])
    expected_attrs = expected.attributes.except(['id', 'created_at', 'updated_at'])
    actual_attrs == expected_attrs
  end
end

RSpec.describe Jira::Client do
  let(:domain) { 'http://www.example.com' }
  let(:username) { 'some_user' }
  let(:password) { 's0m3 passw0rd' }
  let(:params) { ActionController::Parameters.new(username: username, password: password) }

  let(:dummy_response) { '{"foo": "bar"}' }
  let(:issues_response) { File.read('spec/fixtures/responses/issues/just_one.json') }
  let(:rapid_views_response) { '{"views": []}' }

  let(:dummy_query) { 'issuetype=Epic' }

  before(:each) do
    @client = Jira::Client.new(domain, params)
  end

  describe "#request" do
    it "makes a request" do
      stub_request(:get, "https://#{username}:#{password}@www.example.com:80/some/url")
          .to_return(body: dummy_response)

      response = @client.request(:get, 'some/url')

      expect(response).to eq(JSON.parse(dummy_response))
    end
  end

  describe "#search_issues" do
    it "searches for issues with the given query" do
      stub_request(:get, "https://#{username}:#{password}@www.example.com:80/rest/api/2/search?&jql=#{dummy_query}&maxResults=#{Jira::Client::MAX_RESULTS}")
          .to_return(body: issues_response)

      response = @client.search_issues(query: dummy_query)

      expect(response[0]).to be_equivalent_to(Issue.new(key: 'DEMO-101', summary: 'Some Issue'))
    end

    it "pages the results" do
      stub_request(:get, "https://#{username}:#{password}@www.example.com:80/rest/api/2/search?&jql=#{dummy_query}&maxResults=1")
          .to_return(body: File.read('spec/fixtures/responses/issues/one_of_two.json'))

      stub_request(:get, "https://#{username}:#{password}@www.example.com:80/rest/api/2/search?jql=#{dummy_query}&startAt=1&maxResults=1")
          .to_return(body: File.read('spec/fixtures/responses/issues/two_of_two.json'))

      response = @client.search_issues(query: dummy_query, max_results: 1)

      expect(response[0]).to be_equivalent_to(Issue.new(key: 'DEMO-101', summary: 'Issue One'))
      expect(response[1]).to be_equivalent_to(Issue.new(key: 'DEMO-102', summary: 'Issue Two'))
    end

    it "expands the given fields" do
      stub_request(:get, "https://#{username}:#{password}@www.example.com:80/rest/api/2/search?&expand=foo,bar&maxResults=#{Jira::Client::MAX_RESULTS}")
          .to_return(body: issues_response)
      response = @client.search_issues(expand: ['foo', 'bar'])
    end
  end

  describe "#get_rapid_boards" do
    it "fetches the rapid views for the domain" do
      stub_request(:get, "https://#{username}:#{password}@www.example.com:80/rest/greenhopper/1.0/rapidviews/list")
          .to_return(body: rapid_views_response)

      response = @client.get_rapid_boards

      expect(response).to eq([])
    end
  end
end
