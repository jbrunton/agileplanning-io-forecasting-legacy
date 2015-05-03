require 'rails_helper'

RSpec.describe DateFilter do
  describe "#allow_date" do
    it "allows all dates if no filter is specified" do
      filter = DateFilter.new("")
      expect(filter.allow_date(DateTime.now)).to eq(true)
    end

    it "allows dates in a range" do
      filter = DateFilter.new("1 Jul 2015-1 Aug 2015")
      expect(filter.allow_date(DateTime.new(2015, 7, 1))).to eq(true)
      expect(filter.allow_date(DateTime.new(2015, 8, 2))).to eq(false)
    end

    it "allows conjunctions of ranges" do
      filter = DateFilter.new("1 Jul 2015-1 Aug 2015, 1 Sep 2015-1 Oct 2015")
      expect(filter.allow_date(DateTime.new(2015, 7, 1))).to eq(true)
      expect(filter.allow_date(DateTime.new(2015, 8, 2))).to eq(false)
      expect(filter.allow_date(DateTime.new(2015, 9, 1))).to eq(true)
    end
  end

  describe "#allow_issue" do
    let (:issue) { create(:issue, started: DateTime.new(2015, 1, 1), completed: DateTime.new(2015, 1, 5)) }

    it "allows all issues if no filter is specified" do
      filter = DateFilter.new("")
      expect(filter.allow_issue(issue)).to eq(true)
    end

    it "passes if the issue was started and completed in the date range" do
      filter = DateFilter.new("1 Jan 2015-1 Feb 2015")
      expect(filter.allow_issue(issue)).to eq(true)
    end

    it "fails if the issue started date is outside the date range" do
      filter = DateFilter.new("2 Jan 2015-1 Feb 2015")
      expect(filter.allow_issue(issue)).to eq(false)
    end

    it "fails if the issue completed date is outside the date range" do
      filter = DateFilter.new("1 Jan 2015-4 Jan 2015")
      expect(filter.allow_issue(issue)).to eq(false)
    end
  end
end