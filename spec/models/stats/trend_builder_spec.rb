require 'rails_helper'

RSpec.describe Stats::TrendBuilder do
  describe "#analyze" do
    context "when given an empty set" do
      it "returns an empty set" do
        trend = Stats::TrendBuilder.new.analyze([])
        expect(trend).to eq([])
      end
    end

    context "when given a set with one element" do
      let(:series) { [{ x: 5 }] }

      it "transforms the elements as specified" do
        trend = Stats::TrendBuilder.new.
                pluck{ |item| item[:x] }.
                map{ |item, mean, stddev| { value: item[:x], mean: mean, stddev: stddev } }.
                analyze(series)
        expect(trend).to eq([{ value: 5, mean: 5, stddev: 0 }])
      end
    end
  end
end
