require 'rails_helper'

RSpec.describe "Issues", type: :request do
  describe "GET /issues" do
    it "works! (now write some real specs)" do
      get project_issues_path(Project.create!(domain: 'http://www.example.com', board_id: '123', name: 'Some Project'))
      expect(response).to have_http_status(200)
    end
  end
end
