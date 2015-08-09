require 'rails_helper'

RSpec.describe Forecaster do
  let (:now) { DateTime.new(2001, 1, 1) }

  let (:dashboard) {
    create(:dashboard, issues: [
            create(:epic, summary: 'Small [S]', started: now, completed: now + 1.day, cycle_time: 1),
            create(:epic, summary: 'Medium [M]', started: now, completed: now + 2.days, cycle_time: 2)
        ])
  }

  let (:simulator) {
    MonteCarloSimulator.new(dashboard, ::Filters::DateFilter.new(''), 'Epic')
  }

  before(:each) do
    allow(simulator).to receive(:pick_wip_values).and_return([1.0])
    Timecop.freeze(now)
  end

  describe "#forecast_lead_times" do
    let (:opts) {
      {
          sizes: { 'S' => 1, 'M' => 2 },
          wip_scale_factor: 1.0
      }
    }

    let (:total_time) {
      5
    }

    let (:forecaster) {
      forecaster = Forecaster.new(simulator)
    }

    context "if no start date is given" do
      it "forecasts the lead time" do
        forecast = forecaster.forecast_lead_times(opts)
        expect(forecast).to eq([
                    {likelihood: 50, actual_time: total_time},
                    {likelihood: 80, actual_time: total_time},
                    {likelihood: 90, actual_time: total_time}
                ])
      end
    end

    context "if a start date is given" do
      it "forecasts the delivery time" do
        opts.merge!(start_date: now)
        forecast = forecaster.forecast_lead_times(opts)
        expect(forecast).to eq([
                    {likelihood: 50, actual_time: total_time, expected_date: now + total_time.days},
                    {likelihood: 80, actual_time: total_time, expected_date: now + total_time.days},
                    {likelihood: 90, actual_time: total_time, expected_date: now + total_time.days}
                ])
      end
    end

    it "divides by the WIP for issues with rank greater than the computed WIP value" do
      wip = 2.0
      allow(simulator).to receive(:pick_wip_values).and_return([wip])

      forecast = forecaster.forecast_lead_times(opts)

      expect(forecast).to eq([
                  {likelihood: 50, actual_time: total_time / wip },
                  {likelihood: 80, actual_time: total_time / wip },
                  {likelihood: 90, actual_time: total_time / wip }
              ])
    end
  end
end
