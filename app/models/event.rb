class Event
  attr_reader :time
  attr_reader :event_type
  attr_reader :issue

  def initialize(opts)
    @time = opts[:time]
    @event_type = opts[:event_type]
    @issue = opts[:issue]
  end

  def ==(other)
    @time == other.time &&
        @event_type == other.event_type &&
        @issue == other.issue
  end

  def self.compute_for(dashboard)
    events = []

    (dashboard.issues).each do |issue|
      events << Event.new(time: issue.started, event_type: 'started', issue: issue) if (issue.started)
      events << Event.new(time: issue.completed, event_type: 'completed', issue: issue) if (issue.completed)
    end

    events.sort_by{ |event| event.time }
  end
end
