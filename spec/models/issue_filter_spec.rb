require 'rails_helper'

RSpec.describe IssueFilter do
  describe "#allow_issue" do
    let (:issue) { create(:issue, started: DateTime.new(2015, 1, 1), completed: DateTime.new(2015, 1, 5)) }

    it "allows all issues if no filter is specified" do
      filter = IssueFilter.new("")
      expect(filter.allow_issue(issue)).to eq(true)
    end

    it "passes if the issue was started and completed in the date range" do
      filter = IssueFilter.new("complete: 1 Jan 2015-1 Feb 2015")
      expect(filter.allow_issue(issue)).to eq(true)
    end

    it "fails if the issue started date is outside the date range" do
      filter = IssueFilter.new("complete: 2 Jan 2015-1 Feb 2015")
      expect(filter.allow_issue(issue)).to eq(false)
    end

    it "passes if the issue has a cycle time in the given range" do
      filter = IssueFilter.new("cycle_time: 1-10d")
      expect(filter.allow_issue(issue)).to eq(true)
    end

    it "fails if the issue has a cycle time outside the given range" do
      filter = IssueFilter.new("cycle_time: 20-30d")
      expect(filter.allow_issue(issue)).to eq(false)
    end

    it "returns true if all filters pass" do
      filter = IssueFilter.new("cycle_time: 1-10d; complete: 1 Jan 2015-1 Feb 2015")
      expect(filter.allow_issue(issue)).to eq(true)
    end

    it "returns false if one filter fails" do
      filter = IssueFilter.new("cycle_time: 20-30d; complete: 1 Jan 2015-1 Feb 2015")
      expect(filter.allow_issue(issue)).to eq(false)
    end
  end
end
