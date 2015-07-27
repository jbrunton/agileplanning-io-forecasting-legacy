class Forecaster
  def initialize(simulator)
    @simulator = simulator
  end

  def forecast_lead_times(opts)
    total = opts[:sizes].values.reduce(:+)
    opts = opts.merge(rank: total) # to ensure that we don't divide by WIP when total < WIP
    @simulator.play(opts).map do |interval|
      unless opts[:start_date].nil?
        expected_date = opts[:start_date] + interval[:actual_time].days
        interval.merge!(expected_date: expected_date)
      end
      interval
    end
  end
end