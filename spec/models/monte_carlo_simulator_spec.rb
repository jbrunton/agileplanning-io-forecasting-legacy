require 'rails_helper'

RSpec.describe MonteCarloSimulator do
  let (:epics) {
    [
        build(:epic, :completed, cycle_time: 1, small: true),
        build(:epic, :completed, cycle_time: 2, small: true),
        build(:epic, :completed, cycle_time: 3, medium: true),
        build(:epic, :completed, cycle_time: 4, medium: true)
    ]
  }

  let (:simulator) { MonteCarloSimulator.new(epics) }

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

  describe "#play_once" do
    it "returns randomly selected values for the epic sizes given" do
      stub_rand_and_return([1, 0, 1, 0, 1])
      result = simulator.play_once('S' => 2, 'M' => 3)
      expect(result).to eq({
                  actual_time: 14 # 2 + 1 + 4 + 3 + 4
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