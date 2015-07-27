require 'rails_helper'

RSpec.describe Forecaster do
  let (:now) { DateTime.new(2001, 1, 1) }

  let (:dashboard) {
    dashboard = create(:dashboard, issues: [
            create(:issue, started: now, completed: now + 1.day, story_points: '1', cycle_time: 1),
            create(:issue, started: now, completed: now + 2.days, story_points: '2', cycle_time: 2)
        ])
    WipHistory.compute_history_for!(dashboard)
    dashboard
  }

  let (:simulator) {
    Timecop.freeze(now) do
      MonteCarloSimulator.new(dashboard, ::Filters::DateFilter.new(''), 'Story')
    end
  }

  before(:each) do
    allow(simulator).to receive(:pick_wip_values).and_return([2.0])
  end

  describe "#forecast_lead_times" do
    let (:opts) {
      {
          sizes: { 1 => 1, 2 => 1 },
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
                    {likelihood: 50, actual_time: 5},
                    {likelihood: 80, actual_time: 5},
                    {likelihood: 90, actual_time: 5}
                ])
      end
    end

    context "if a start date is given" do
      it "forecasts the delivery time" do
        opts.merge!(start_date: now)
        forecast = forecaster.forecast_lead_times(opts)

        expect(forecast).to eq([
                    {likelihood: 50, actual_time: 5, expected_date: now + 5.days},
                    {likelihood: 80, actual_time: 5, expected_date: now + 5.days},
                    {likelihood: 90, actual_time: 5, expected_date: now + 5.days}
                ])
      end
    end

    it "divides by the WIP for issues with rank greater than the computed WIP value" do
      opts[:sizes] = { 1 => 4, 2 => 4 }
      forecast = forecaster.forecast_lead_times(opts)
      expect(forecast).to eq([
                  {likelihood: 50, actual_time: 5, expected_date: now + 5.days},
                  {likelihood: 80, actual_time: 5, expected_date: now + 5.days},
                  {likelihood: 90, actual_time: 5, expected_date: now + 5.days}
              ])
    end
  end
end
