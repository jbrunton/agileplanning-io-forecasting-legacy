require 'rails_helper'

RSpec.describe WipHistory, type: :model do
  describe ".compute_history_for" do
    it "builds the wip history for the given dashboard" do
      start_time = DateTime.parse('2015-01-01T12:00:00.000+0100')
      start_date = start_time.to_date
      epic = create(:epic, started: start_time, completed: start_time + 2.days)
      story = create(:issue, started: epic.started + 1.day, completed: epic.completed + 1.day)
      project = create(:dashboard, issues: [epic, story])

      history = WipHistory.compute_history_for!(project)

      expect(simplify_history(project)).to eq [
                  { date: start_date, issue: epic, issue_type: 'Epic' },
                  { date: start_date + 1.day, issue: epic, issue_type: 'Epic' },
                  { date: start_date + 1.day, issue: story, issue_type: 'Story' },
                  { date: start_date + 2.day, issue: story, issue_type: 'Story' }
              ]
    end
  end

  def simplify_history(project)
    project.wip_histories.map do |history|
      { date: history.date, issue: history.issue, issue_type: history.issue_type }
    end
  end
end