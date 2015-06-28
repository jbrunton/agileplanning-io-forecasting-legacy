require "rails_helper"

RSpec.describe DashboardsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/dashboards").to route_to("projects#index")
    end

    it "routes to #new" do
      expect(:get => "/dashboards/new").to route_to("projects#new")
    end

    it "routes to #show" do
      expect(:get => "/dashboards/1").to route_to("projects#show", :id => "1")
    end

    it "routes to #sync" do
      expect(:post => "/dashboards/1/sync").to route_to("projects#sync", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/dashboards/1/edit").to route_to("projects#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/dashboards").to route_to("projects#create")
    end

    it "routes to #update" do
      expect(:put => "/dashboards/1").to route_to("projects#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/dashboards/1").to route_to("projects#destroy", :id => "1")
    end

  end
end
