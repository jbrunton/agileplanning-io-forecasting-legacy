require 'rails_helper'

RSpec.describe "Issues", type: :request do
  describe "GET /issues" do
    let(:dashboard) { create(:dashboard) }

    it "works! (now write some real specs)" do
      get project_issues_path(dashboard)
      expect(response).to have_http_status(200)
    end
  end
end
