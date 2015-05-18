class DateRange
  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def to_a
    dates = [@start_date]
    while dates.last < @end_date - 1.day
      dates << (dates.last + 1.day)
    end
    dates
  end
end