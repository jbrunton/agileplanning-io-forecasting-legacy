class Filters::DateFilter
  def initialize(filter)
    @date_ranges = filter.split(",").map do |x|
      x.split("-").map{ |x| DateTime.parse(x.strip) }
    end
  end

  def allow_date(date)
    return true if @date_ranges.empty?
    @date_ranges.select{ |range| range[0] <= date && date <= range[1] }.length > 0
  end

  def allow_issue(issue)
    return true if @date_ranges.empty?
    @date_ranges.select{ |range| range[0] <= issue.started && issue.completed <= range[1] }.length > 0
  end
end
