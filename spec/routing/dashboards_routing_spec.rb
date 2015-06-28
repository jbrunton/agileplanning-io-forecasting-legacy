require "rails_helper"

RSpec.describe DashboardsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "domains/1/dashboards").to route_to("dashboards#index", :domain_id => "1")
    end

    it "routes to #show" do
      expect(:get => "/dashboards/1").to route_to("dashboards#show", :id => "1")
    end

    it "routes to #sync" do
      expect(:post => "/dashboards/1/sync").to route_to("dashboards#sync", :id => "1")
    end
  end
end
