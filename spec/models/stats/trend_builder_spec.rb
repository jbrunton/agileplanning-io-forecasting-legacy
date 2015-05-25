require 'rails_helper'

RSpec.describe Stats::TrendBuilder do
  let (:builder) { Stats::TrendBuilder.new }

  describe "#analyze" do
    context "when given an empty series" do
      it "returns an empty list" do
        trend = builder.analyze([])
        expect(trend).to eq([])
      end
    end

    context "when given a set with one element" do
      let(:series) { [{ x: 5 }] }

      it "transforms the elements as specified" do
        trend = builder.
                pluck{ |item| item[:x] }.
                map{ |item, mean, stddev| { value: item[:x], mean: mean, stddev: stddev } }.
                analyze(series)
        expect(trend).to eq([{ value: 5, mean: 5, stddev: 0 }])
      end
    end

    context "when given a series" do
      let(:series) {[
          { x: 2 },
          { x: 2 },
          { x: 2 },
          { x: 2 },
          { x: 2 },
          { x: 4 }
      ]}

      it "calculates the rolling mean and stddev" do
        
      end
    end
  end

  describe ".sample_size" do
    context "for large series" do
      it "returns a value 20% the size of the sample" do
        expect(Stats::TrendBuilder.sample_size(45)).to eql(9)
      end

      it "returns the next odd number, to ensure the sample can be centered at the given index" do
        expect(Stats::TrendBuilder.sample_size(100)).to eql(21)
      end
    end

    context "for small series" do
      it "returns a minimum size of 5" do
        expect(Stats::TrendBuilder.sample_size(10)).to eql(5)
      end
    end
  end

  describe ".pick_sample" do
    let (:series) { (1..20).to_a }

    context "when given an empty series" do
      it "returns an empty list" do
        sample = Stats::TrendBuilder.pick_sample([], 1)
        expect(sample).to eq([])
      end
    end

    context "when index is in the middle of the series" do
      it "returns a sample centred around the index" do
        sample = Stats::TrendBuilder.pick_sample(series, 10)
        expect(sample).to eq([8, 9, 10, 11, 12])
      end
    end

    context "when index is towards the start of the series" do
      it "returns a sample starting at the 0 index" do
        sample = Stats::TrendBuilder.pick_sample(series, 1)
        expect(sample).to eq([1, 2, 3, 4, 5])
      end
    end

    context "when index is towards the end of the series" do
      it "returns a sample ending at the last index" do
        sample = Stats::TrendBuilder.pick_sample(series, 19)
        expect(sample).to eq([16, 17, 18, 19, 20])
      end
    end

    context "when the sample size is small" do
      it "returns the whole series" do
        sample = Stats::TrendBuilder.pick_sample([3, 4, 5], 2)
        expect(sample).to eq([3, 4, 5])
      end
    end
  end
end
