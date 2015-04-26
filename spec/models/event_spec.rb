require 'rails_helper'

RSpec.describe Event do
  describe "#compute_for" do
    let(:epic_one) { create(:issue, :completed, issue_type: 'Epic') }
    let(:epic_two) { create(:issue, issue_type: 'Epic', started: epic_one.started + 1.minute, completed: epic_one.completed + 1.minute) }
    let(:project) { create(:project, issues: [epic_one, epic_two]) }

    it "computes the events for a project in order" do
      events = Event.compute_for(project)
      expect(events).to eq([
                  Event.new(time: epic_one.started, event_type: 'started', epic: epic_one),
                  Event.new(time: epic_two.started, event_type: 'started', epic: epic_two),
                  Event.new(time: epic_one.completed, event_type: 'completed', epic: epic_one),
                  Event.new(time: epic_two.completed, event_type: 'completed', epic: epic_two)
              ])
    end
  end
end