require 'rails_helper'

RSpec.describe Jira::RapidBoardBuilder do
  describe "#build" do
    let (:json) {
      <<-END
      {
        "id": 2,
        "name": "Some Dashboard",
        "filter":
        {
          "id": 10001,
          "name": "Filter for Another Dashboard",
          "query": "dashboard = \\"Another Dashboard\\" ORDER BY Rank ASC"
        }
      }
      END
    }

    let(:rapid_board) { Jira::RapidBoardBuilder.new(JSON.parse(json)).build }

    it "sets the id" do
      expect(rapid_board.id).to eq(2)
    end

    it "sets the name" do
      expect(rapid_board.name).to eq('Some Dashboard')
    end
  end
end
