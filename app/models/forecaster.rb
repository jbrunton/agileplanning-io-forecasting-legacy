class Forecaster
  def initialize(simulator)
    @simulator = simulator
  end

  def forecast_lead_times(opts)
    total = opts[:sizes].values.reduce(:+)
    opts = opts.merge(rank: total) # to ensure that we don't divide by WIP when total < WIP
    @simulator.play(opts).map do |confidence_level|
      if opts[:start_date]
        expected_date = opts[:start_date] + confidence_level[:actual_time].days
        confidence_level.merge!(expected_date: expected_date)
      end
      confidence_level
    end
  end

  def forecast_backlog(backlog, opts)
    return [] if backlog.upcoming.length == 0

    opts = {
        sizes: {'S' => 0, 'M' => 0, 'L' => 0, '?' => 0}
    }
    
    backlog.upcoming.each_with_index.map do |issue, index|
      opts[:rank] = index + 1

      size = issue.size || '?'
      opts[:sizes][size] = opts[:sizes][size] + 1

      { issue: issue, forecast: forecast_lead_times(opts) }
    end
  end
end