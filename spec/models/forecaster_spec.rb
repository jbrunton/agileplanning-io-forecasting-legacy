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
    Timecop.freeze(now) do
      WipHistory.compute_history_for!(dashboard)
      MonteCarloSimulator.new(dashboard, ::Filters::DateFilter.new(''), 'Epic')
    end
  }

  before(:each) do
    allow(simulator).to receive(:pick_wip_values).and_return([1.0])
  end

  describe "#forecast_lead_times" do
    let (:opts) {
      {
          sizes: { 'S' => 1, 'M' => 1 },
          wip_scale_factor: 1.0
      }
    }

    let (:forecaster) {
      forecaster = Forecaster.new(simulator)
    }

    context "if no start date is given" do
      it "forecasts the lead time" do
        forecast = forecaster.forecast_lead_times(opts)
        expect(forecast).to eq([
                    {likelihood: 50, actual_time: 3},
                    {likelihood: 80, actual_time: 3},
                    {likelihood: 90, actual_time: 3}
                ])
      end
    end

    context "if a start date is given" do
      it "forecasts the delivery time" do
        opts.merge!(start_date: now)
        forecast = forecaster.forecast_lead_times(opts)
        expect(forecast).to eq([
                    {likelihood: 50, actual_time: 3, expected_date: now + 3.days},
                    {likelihood: 80, actual_time: 3, expected_date: now + 3.days},
                    {likelihood: 90, actual_time: 3, expected_date: now + 3.days}
                ])
      end
    end

    it "divides by the WIP for issues with rank greater than the computed WIP value" do
      allow(simulator).to receive(:pick_wip_values).and_return([2.0])
      forecast = forecaster.forecast_lead_times(opts)
      expect(forecast).to eq([
                  {likelihood: 50, actual_time: 2 },
                  {likelihood: 80, actual_time: 2 },
                  {likelihood: 90, actual_time: 2 }
              ])
    end
  end
end
