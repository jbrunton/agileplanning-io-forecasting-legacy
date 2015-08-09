require 'rails_helper'

RSpec.describe Forecaster do
  let (:now) { DateTime.new(2001, 1, 1) }

  before(:each) do
    allow(simulator).to receive(:pick_wip_values).and_return([1.0])
    Timecop.freeze(now)
  end

  describe "#forecast_lead_times" do
    let (:dashboard) {
      create(:dashboard, issues: [
              create(:epic, summary: 'Small [S]', started: now, completed: now + 1.day, cycle_time: 1),
              create(:epic, summary: 'Medium [M]', started: now, completed: now + 2.days, cycle_time: 2)
          ])
    }

    let(:simulator) { build_simulator_for(dashboard) }
    let(:forecaster) { forecaster = Forecaster.new(simulator) }

    let (:opts) {
      {
          sizes: { 'S' => 1, 'M' => 2 },
          wip_scale_factor: 1.0
      }
    }

    let (:total_time) {
      5
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
  describe "#forecast_backlog" do
    let(:opts) { {} }

    context "if the backlog has no items" do
      let(:dashboard) { create(:dashboard) }
      let(:simulator) { build_simulator_for(dashboard) }
      let(:forecaster) { forecaster = Forecaster.new(simulator) }
      let(:backlog) { build_backlog_for(dashboard) }

      it "returns an empty list" do
        expect(forecaster.forecast_backlog(backlog, opts)).to eq([])
      end
    end

    context "if the backlog has one item" do
      let(:epic) { create(:epic, summary: 'Small [S]') }

      let(:dashboard) {
        completed_epics = [
            create(:epic, :completed, summary: 'Small [S]', cycle_time: 2),
            create(:epic, :completed, summary: 'Medium [M]', cycle_time: 4)
        ]
        backlog = [
            epic
        ]
        create(:dashboard, issues: completed_epics + backlog)
      }

      let(:simulator) { build_simulator_for(dashboard) }
      let(:forecaster) { forecaster = Forecaster.new(simulator) }
      let(:backlog) { build_backlog_for(dashboard) }

      it "returns a forecast for the issue" do
        expected_backlog = [
            { issue: epic, forecast: [
                {likelihood: 50, actual_time: 2},
                {likelihood: 80, actual_time: 2},
                {likelihood: 90, actual_time: 2}
            ]}
        ]
        expect(forecaster.forecast_backlog(backlog, opts)).to eq(expected_backlog)
      end
    end

    context "if the backlog has multiple items" do
      let(:first_epic) { create(:epic, summary: 'Small [S]') }
      let(:second_epic) { create(:epic, summary: 'Small [M]') }

      let(:dashboard) {
        completed_epics = [
            create(:epic, :completed, summary: 'Small [S]', cycle_time: 2),
            create(:epic, :completed, summary: 'Medium [M]', cycle_time: 4)
        ]
        backlog = [
            first_epic,
            second_epic
        ]
        create(:dashboard, issues: completed_epics + backlog)
      }

      let(:simulator) { build_simulator_for(dashboard) }
      let(:forecaster) { forecaster = Forecaster.new(simulator) }
      let(:backlog) { build_backlog_for(dashboard) }

      it "returns a forecast for the issue" do
        expected_backlog = [
            { issue: first_epic, forecast: [
                {likelihood: 50, actual_time: 2},
                {likelihood: 80, actual_time: 2},
                {likelihood: 90, actual_time: 2}
            ]},
            { issue: second_epic, forecast: [
                {likelihood: 50, actual_time: 6},
                {likelihood: 80, actual_time: 6},
                {likelihood: 90, actual_time: 6}
            ]}
        ]
        expect(forecaster.forecast_backlog(backlog, opts)).to eq(expected_backlog)
      end
    end
  end

  def build_simulator_for(dashboard)
    MonteCarloSimulator.new(dashboard, ::Filters::DateFilter.new(''), 'Epic')
  end

  def build_backlog_for(dashboard)
    Backlog::Builder.new(dashboard, 'Epic').build
  end
end
