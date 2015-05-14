require 'rails_helper'

RSpec.describe DateRange do
  describe "#to_a" do
    it "returns all the dates in the given range" do
      start_date = Date.new(2001, 1, 1)
      end_date = start_date + 3.days

      expect(DateRange.new(start_date, end_date).to_a).to eq([
                  start_date,
                  start_date + 1.day,
                  start_date + 2.days
              ])
    end
  end
end