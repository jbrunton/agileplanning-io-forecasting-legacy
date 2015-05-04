class MonteCarloSimulator
  attr_reader :random
  attr_reader :epic_values
  attr_reader :wip_values

  PLAY_COUNT = 100

  def initialize(project)
    @random = Random.new(0)
    @epic_values = project.epics.
        group_by{ |epic| epic.size }.
        map{ |size, epics| [size, epics.map{ |epic| epic.cycle_time }] }.to_h
    @wip_values = project.wip_histories.
        group_by{ |h| h.date }.
        values.map{ |histories| histories.length }
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

  def pick_wip_values(count)
    pick_values(@wip_values, count)
  end

  def play_once(opts)
    cycle_time_values = pick_cycle_time_values(opts)
    wip_values = pick_wip_values(10)

    total_time = cycle_time_values.reduce(:+)
    average_wip = wip_values.reduce(:+) / wip_values.length

    { total_time: total_time, average_wip: average_wip, actual_time: total_time / average_wip }
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