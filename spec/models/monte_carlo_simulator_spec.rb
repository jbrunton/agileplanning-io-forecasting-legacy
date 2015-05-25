require 'rails_helper'

RSpec.describe MonteCarloSimulator do
  before(:each) do
    MonteCarloSimulator.send(:public, *MonteCarloSimulator.protected_instance_methods)
  end

  let (:start_date) { DateTime.new(2001, 1, 1) }
  let (:filter) { DateFilter.new("1 Jan 2001-5 Jan 2001")}

  let (:project) {
    epics = [
        build(:epic, :completed, started: start_date, cycle_time: 1, small: true),
        build(:epic, :completed, started: start_date, cycle_time: 2, small: true),
        build(:epic, :completed, started: start_date, cycle_time: 3, medium: true),
        build(:epic, :completed, started: start_date, cycle_time: 4, medium: true),
        build(:epic, :completed, started: start_date + 10.days, cycle_time: 1, small: true)
    ]
    project = create(:project, issues: epics)
    WipHistory.compute_history_for!(project)
    project
  }

  let (:now) { start_date + 5.5.days }

  let (:simulator) {
    Timecop.freeze(now) do
      MonteCarloSimulator.new(project, filter)
    end
  }

  describe "#epic_values" do
    it "returns the sets of filtered epic values grouped by size" do
      expect(simulator.epic_values).to eq({
                  'S' => [1.0, 2.0],
                  'M' => [3.0, 4.0],
                  '?' => [1.0, 2.0, 3.0, 4.0]
              })
    end
  end

  describe "#wip_values" do
    it "returns the set of filtered wip values for the project" do
      expect(simulator.wip_values).to eq([4, 3, 2, 1, 0])
    end
  end

  describe "#pick_values" do
    it "returns the empty array when asked to pick 0 values" do
      values = simulator.pick_values([1, 2, 3], 0)
      expect(values).to eq([])
    end

    it "returns 2 randomly selected values for the size when asked to pick 2 values" do
      stub_rand_and_return([1, 0])
      values = simulator.pick_values([1, 2, 3], 2)
      expect(values).to eq([2, 1])
    end
  end

  describe "#pick_cycle_time_values" do
    it "returns randomly selected cycle time values for the epic sizes given" do
      stub_rand_and_return([1, 0, 1, 0, 1])
      result = simulator.pick_cycle_time_values('S' => 2, 'M' => 3)
      expect(result).to eq([2, 1, 4, 3, 4])
    end

    it "falls back to the unsized category if no data exists for the given category" do
      allow(simulator).to receive(:epic_values).and_return('S' => [1], '?' => [2])
      result = simulator.pick_cycle_time_values('S' => 1, 'M' => 1)
      expect(result).to eq([1, 2])
    end
  end

  describe "#pick_wip_values" do
    it "returns k randomly selected wip values" do
      stub_rand_and_return([0, 1, 2, 3, 0])
      result = simulator.pick_wip_values(5)
      expect(result).to eq([4, 3, 2, 1, 4])
    end
  end

  describe "#play_once" do
    it "executes a single run of the Monte Carlo simulator" do
      allow(simulator).to receive(:pick_cycle_time_values).and_return([1, 2, 3, 4, 2])
      allow(simulator).to receive(:pick_wip_values).and_return([1, 2, 3])

      result = simulator.play_once(:sizes => { 'S' => 2, 'M' => 3 })

      expect(result).to eq({
                  total_time: 12, # sum of cycle time values
                  average_wip: 2, # mean of wip values
                  actual_time: 6  # total_time / average_wip
              })
    end

    it "scales the WIP values by 'wip_scale_factor' if given as an option" do
      allow(simulator).to receive(:pick_cycle_time_values).and_return([1, 2, 3, 4, 2])
      allow(simulator).to receive(:pick_wip_values).and_return([1, 2, 3])

      result = simulator.play_once({
              :sizes => { 'S' => 2, 'M' => 3 },
              :wip_scale_factor => 1.5
          })

      expect(result).to eq({
                  total_time: 12, # sum of cycle time values
                  average_wip: 3, # mean of wip values * wip_scale_factor
                  actual_time: 4  # total_time / average_wip
              })
    end
  end

  describe "#play" do
    it "plays the simulator 100 times and forecasts using the results" do
      dummy_opts = {}
      stub_simulator_to_play([
              { actual_time: 2 },
              { actual_time: 2 },
              { actual_time: 2 },
              { actual_time: 2 },
              { actual_time: 2 },
              { actual_time: 5 },
              { actual_time: 5 },
              { actual_time: 5 },
              { actual_time: 7 },
              { actual_time: 9 }
          ])

      forecast = simulator.play(dummy_opts)

      expect(forecast).to eq([
                  { likelihood: 50, actual_time: 2 },
                  { likelihood: 80, actual_time: 5 },
                  { likelihood: 90, actual_time: 7 }
              ])
    end
  end

  def stub_rand_and_return(values)
    index = 0
    allow(simulator.random).to receive(:rand).with(anything) do
      index += 1
      values[index - 1]
    end
  end

  def stub_simulator_to_play(results)
    index = 0
    allow(simulator).to receive(:play_once) do
      index += 1
      result = results[index - 1]
      index = 0 if index == results.length
      result
    end
  end
end