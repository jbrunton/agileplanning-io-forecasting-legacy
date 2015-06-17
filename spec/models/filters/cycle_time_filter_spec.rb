require 'rails_helper'

RSpec.describe Filters::CycleTimeFilter do
  describe "#allow_cycle_time" do
    let(:filter) { Filters::CycleTimeFilter.new("5-10d") }

    it "allows cycle times in the given range" do
      expect(filter.allow_cycle_time(7)).to eq(true)
    end

    it "disallows cycle times outside the given range" do
      expect(filter.allow_cycle_time(2)).to eq(false)
      expect(filter.allow_cycle_time(12)).to eq(false)
    end
  end

  describe "#allow_issue" do
    let(:issue) { create(:issue, started: DateTime.new(2015, 1, 1), completed: DateTime.new(2015, 1, 5)) }

    it "allows issues with cycle times in the given range" do
      filter = Filters::CycleTimeFilter.new("1-10d")
      expect(filter.allow_issue(issue)).to eq(true)
    end

    it "disallows issues with cycle times outside the given range" do
      filter = Filters::CycleTimeFilter.new("1-2d")
      expect(filter.allow_issue(issue)).to eq(false)
    end
  end
end