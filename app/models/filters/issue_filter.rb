class Filters::IssueFilter
  DATE_FILTER = /complete: (.*)/
  CYCLE_TIME_FILTER = /cycle_time: (.*)/


  def initialize(filter)
    @filters = filter.split(";").map do |x|
      case x
        when DATE_FILTER
          Filters::DateFilter.new($1)
        when CYCLE_TIME_FILTER
          Filters::CycleTimeFilter.new($1)
      end
    end
  end

  def allow_issue(issue)
    return true if @filters.empty?
    @filters.all?{ |filter| filter.allow_issue(issue) }
  end

  def allow_date(date)
    return true if @filters.empty?
    @filters.select{ |f| f.class == Filters::DateFilter }.all?{ |f| f.allow_date(date) }
  end
end
