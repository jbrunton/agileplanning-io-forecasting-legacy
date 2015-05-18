class WipHistory < ActiveRecord::Base
  belongs_to :issue

  def self.compute_history_for!(project)
    events = Event.compute_for(project)
    return if events.length == 0

    events_by_date = events.group_by{ |e| e.time.to_date }

    from_date = events.first.time.to_date
    to_date = events.last.time.to_date + 1.day

    epics = []
    dates = DateRange.new(from_date, to_date).to_a
    dates.each do |date|
      events_for_day = events.select{ |e| date <= e.time && e.time < date + 1.day }
      started_events = events_for_day.select{ |e| e.event_type == 'started' }
      completed_events = events_for_day.select{ |e| e.event_type == 'completed' }

      started_events.each{ |event| epics << event.epic }
      completed_events.each{ |event| epics.delete(event.epic) }

      epics.each{ |epic| WipHistory.create(date: date, issue: epic) }
    end
  end
end
