class Event
  attr_reader :time
  attr_reader :event_type
  attr_reader :issue
  attr_reader :issue_type

  def initialize(opts)
    @time = opts[:time]
    @event_type = opts[:event_type]
    @issue = opts[:issue]
    @issue_type = opts[:issue_type]
  end

  def ==(other)
    @time == other.time &&
        @event_type == other.event_type &&
        @issue == other.issue &&
        @issue_type == other.issue_type
  end

  def self.compute_for(project)
    events = []

    (project.epics + project.stories).each do |issue|
      events << Event.new(time: issue.started, event_type: 'started', issue: issue, issue_type: issue.issue_type) if (issue.started)
      events << Event.new(time: issue.completed, event_type: 'completed', issue: issue, issue_type: issue.issue_type) if (issue.completed)
    end

    events.sort_by{ |event| event.time }
  end
end
