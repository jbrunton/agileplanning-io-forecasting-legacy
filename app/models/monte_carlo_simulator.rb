class MonteCarloSimulator
  attr_reader :random
  attr_reader :epic_values

  PLAY_COUNT = 100

  def initialize(epics)
    @random = Random.new(0)
    @epic_values = epics.
        group_by{ |epic| epic.size }.
        map{ |size, epics| [size, epics.map{ |epic| epic.cycle_time }] }.to_h
  end

protected
  def pick_values(values, count)
    result = []
    count.times do
      result << values[@random.rand(values.length)]
    end
    result
  end

  def pick_cycle_time_values(opts)
    values = []
    opts.each do |size, count|
      values.concat(pick_values(@epic_values[size], count))
    end
    values
  end

  def play_once(opts)
    cycle_time_values = pick_cycle_time_values(opts)
    { total_time: cycle_time_values.reduce(:+) }
  end

  def play(opts)
    results = []
    PLAY_COUNT.times do
      results << play_once(opts)
    end
    results.sort_by!{ |result| result[:actual_time] }
    [
        { likelihood: 50, actual_time: results[PLAY_COUNT * 0.5 - 1][:actual_time] },
        { likelihood: 80, actual_time: results[PLAY_COUNT * 0.8 - 1][:actual_time] },
        { likelihood: 90, actual_time: results[PLAY_COUNT * 0.9 - 1][:actual_time] }
    ]
  end
end