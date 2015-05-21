require "rails_helper"

RSpec.describe DataController, type: :routing do
  describe "routing" do
    it "routes to #cycle_times" do
      expect(:get => "/projects/1/data/cycle_times").to route_to("data#cycle_times", :id => "1")
    end

    it "routes to #wip" do
      expect(:get => "/projects/1/data/wip").to route_to("data#wip", :id => "1")
    end
  end
end
