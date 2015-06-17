require 'rails_helper'

RSpec.describe Event do
  describe "#compute_for" do
    let(:epic) { create(:epic, :completed) }
    let(:story) { create(:issue, started: epic.started + 1.minute, completed: epic.completed + 1.minute) }
    let(:project) { create(:project, issues: [epic, story]) }

    it "computes the events for a project in order" do
      events = Event.compute_for(project)
      expect(events).to eq([
                  Event.new(time: epic.started, event_type: 'started', issue: epic, issue_type: 'Epic'),
                  Event.new(time: story.started, event_type: 'started', issue: story, issue_type: 'Story'),
                  Event.new(time: epic.completed, event_type: 'completed', issue: epic, issue_type: 'Epic'),
                  Event.new(time: story.completed, event_type: 'completed', issue: story, issue_type: 'Story')
              ])
    end
  end
end