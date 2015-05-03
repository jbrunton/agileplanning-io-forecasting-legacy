class MonteCarloSimulator
  attr_reader :random

  PLAY_COUNT = 100

  def initialize(epics)
    @random = Random.new(0)
    @epics = epics
  end

  def pick_values(values, count)
    result = []
    count.times do
      result << values[@random.rand(values.length)]
    end
    result
  end

  def play_once(opts)
    total_time = 0
    opts.each do |size, count|
      epics = @epics.select{ |epic| epic.size == size }
      total_time += pick_values(epics.map{ |epic| epic.cycle_time }, count).inject(:+)
    end
    { actual_time: total_time }
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