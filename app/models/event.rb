class Event
  attr_reader :time
  attr_reader :event_type
  attr_reader :epic

  def initialize(opts)
    @time = opts[:time]
    @event_type = opts[:event_type]
    @epic = opts[:epic]
  end

  def ==(other)
    @time == other.time &&
        @event_type == other.event_type &&
        @epic == other.epic
  end

  def self.compute_for(project)
    events = []

    project.epics.each do |epic|
      events << Event.new(time: epic.started, event_type: 'started', epic: epic) if (epic.started)
      events << Event.new(time: epic.completed, event_type: 'completed', epic: epic) if (epic.completed)
    end

    events.sort_by{ |event| event.time }
  end
end
