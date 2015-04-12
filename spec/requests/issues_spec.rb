require 'rails_helper'

RSpec.describe "Issues", type: :request do
  describe "GET /issues" do
    let(:project) { create(:project) }

    it "works! (now write some real specs)" do
      get project_issues_path(project)
      expect(response).to have_http_status(200)
    end
  end
end
