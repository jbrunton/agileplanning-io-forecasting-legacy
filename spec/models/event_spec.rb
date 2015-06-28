require 'rails_helper'

RSpec.describe Event do
  describe "#compute_for" do
    let(:epic) { create(:epic, :completed) }
    let(:story) { create(:issue, started: epic.started + 1.minute, completed: epic.completed + 1.minute) }
    let(:dashboard) { create(:dashboard, issues: [epic, story]) }

    it "computes the events for a dashboard in order" do
      events = Event.compute_for(dashboard)
      expect(events).to eq([
                  Event.new(time: epic.started, event_type: 'started', issue: epic),
                  Event.new(time: story.started, event_type: 'started', issue: story),
                  Event.new(time: epic.completed, event_type: 'completed', issue: epic),
                  Event.new(time: story.completed, event_type: 'completed', issue: story)
              ])
    end
  end
end