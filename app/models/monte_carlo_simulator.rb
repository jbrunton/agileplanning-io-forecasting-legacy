class MonteCarloSimulator
  attr_reader :random
  attr_reader :cycle_time_values
  attr_reader :wip_values

  PLAY_COUNT = 100

  def initialize(project, filter)
    @random = Random.new(0)
    @cycle_time_values = compute_cycle_time_values(project, filter)
    @wip_values = compute_wip_values(project, filter)
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

protected
  def pick_values(values, count)
    result = []
    count.times do
      result << values[@random.rand(values.length)]
    end
    result
  end

  def pick_cycle_time_values(sizes)
    values = []
    sizes.each do |size, count|
      values_for_size = cycle_time_values[size]
      values_for_size = cycle_time_values['?'] if values_for_size.nil?
      values.concat(pick_values(values_for_size, count))
    end
    values
  end

  def pick_wip_values(count)
    pick_values(@wip_values, count)
  end

  def play_once(opts)
    wip_values = pick_wip_values(10)
    average_wip = wip_values.reduce(:+) / wip_values.length
    average_wip = average_wip * opts[:wip_scale_factor] if opts[:wip_scale_factor]

    if opts[:rank] >= average_wip
      sizes = opts[:sizes]
    else
      sizes = { opts[:size] => 1 }
    end

    cycle_time_values = pick_cycle_time_values(sizes)
    total_time = cycle_time_values.reduce(:+)


    actual_time = total_time
    actual_time = total_time / average_wip if opts[:rank] >= average_wip

    { total_time: total_time, average_wip: average_wip, actual_time: actual_time }
  end

  def compute_cycle_time_values(project, filter)
    partitioned_values = project.epics.
        select{ |epic| epic.cycle_time && filter.allow_issue(epic) }.
        group_by{ |epic| epic.size }.
        map{ |size, epics| [size, epics.map{ |epic| epic.cycle_time }] }.to_h

    partitioned_values.merge({'?' => partitioned_values.values.flatten})
  end

  def compute_wip_values(project, filter)
    project.complete_wip_history('Epic').
        select{ |date, issues| filter.allow_date(date) }.
        values.
        map{ |issues| issues.length }
  end
end