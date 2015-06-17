class Filters::CycleTimeFilter
  FILTER = /(\d+)-(\d+)d/

  def initialize(filter)
    match = FILTER.match(filter)
    @min, @max = match[1..2].map{ |x| x.to_i } unless match.nil?
  end

  def allow_cycle_time(cycle_time)
    @min <= cycle_time && cycle_time <= @max
  end

  def allow_issue(issue)
    allow_cycle_time(issue.cycle_time)
  end
end
