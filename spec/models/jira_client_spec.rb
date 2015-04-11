require 'rails_helper'

RSpec.describe JiraClient do
  let(:domain) { 'http://www.example.com' }
  let(:username) { 'some_user' }
  let(:password) { 's0m3 passw0rd' }
  let(:params) { ActionController::Parameters.new(username: username, password: password) }

  let(:dummy_response) { '{"foo": "bar"}' }
  let(:issues_response) { '{"issues": []}' }
  let(:rapid_views_response) { '{"views": []}' }

  let(:dummy_query) { 'issuetype=Epic' }

  before(:each) do
    @client = JiraClient.new(domain, params)
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
      stub_request(:get, "https://#{username}:#{password}@www.example.com:80/rest/api/2/search?maxResults=9999&jql=#{dummy_query}")
          .to_return(body: issues_response)

      response = @client.search_issues(query: dummy_query)

      expect(response).to eq([])
    end

    it "expands the given fields" do
      stub_request(:get, "https://#{username}:#{password}@www.example.com:80/rest/api/2/search?maxResults=9999&expand=foo,bar")
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
