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
end