require 'rails_helper'

RSpec.describe DateRange do
  describe "#to_a" do
    let(:start_date) { Date.new(2001, 1, 1) }

    context "if the range is empty" do
      let(:range) { DateRange.new(start_date, start_date) }

      it "returns an empty list" do
        expect(range.to_a).to eq([])
      end
    end

    context "if the end date is 1 day ahead of the start" do
      let(:range) { DateRange.new(start_date, start_date + 1.day) }

      it "returns one date (i.e. is end-exclusive)" do
        expect(range.to_a).to eq([start_date])
      end
    end

    context "if the range spans multiple days" do
      let(:range) { DateRange.new(start_date, start_date + 3.days) }

      it "rreturns all the dates in the range" do
        expect(range.to_a).to eq([
                    start_date,
                    start_date + 1.day,
                    start_date + 2.day])
      end
    end
  end
end