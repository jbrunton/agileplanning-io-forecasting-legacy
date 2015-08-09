class MonteCarloSimulator
  attr_reader :random
  attr_reader :cycle_time_values
  attr_reader :wip_values

  PLAY_COUNT = 100

  def initialize(dashboard, filter, issue_type)
    @random = Random.new(0)
    @cycle_time_values = compute_cycle_time_values(dashboard, filter, issue_type)
    @wip_values = compute_wip_values(dashboard, filter, issue_type)
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
    rank_greater_than_wip = opts[:rank] > average_wip

    if opts[:size] && !rank_greater_than_wip
      # If rank <= wip, then we can't scale by WIP (see also: Mythical Man Month).
      sizes = { opts[:size] => 1 }
    else
      sizes = opts[:sizes]
    end

    cycle_time_values = pick_cycle_time_values(sizes)

    if rank_greater_than_wip
      # If rank > WIP, sum cycle times so we can divide by WIP
      total_time = cycle_time_values.reduce(:+)
    else
      # Otherwise, the tasks have to be worked on in parallel, so the aggregate
      # cycle time is equal to the max of the individual issues
      total_time = cycle_time_values.max
    end


    actual_time = total_time
    actual_time = total_time / average_wip if rank_greater_than_wip

    { total_time: total_time, average_wip: average_wip, actual_time: actual_time }
  end

  def compute_cycle_time_values(dashboard, filter, issue_type)
    partitioned_values = dashboard.issues.
        select{ |issue| issue.issue_type == issue_type && issue.cycle_time && filter.allow_issue(issue) }.
        group_by{ |issue| issue.size }.
        map{ |size, issues| [size, issues.map{ |issue| issue.cycle_time }] }.to_h

    partitioned_values.merge({'?' => partitioned_values.values.flatten})
  end

  def compute_wip_values(dashboard, filter, issue_type)
    dashboard.wip_history(issue_type).
        select{ |date, issues| filter.allow_date(date) }.
        values.
        map{ |issues| issues.length }
  end
end