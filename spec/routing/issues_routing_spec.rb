require "rails_helper"

RSpec.describe IssuesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/projects/2/issues").to route_to("issues#index", :project_id => "2")
    end

    it "routes to #show" do
      expect(:get => "/issues/1").to route_to("issues#show", :id => "1")
    end
  end
end
