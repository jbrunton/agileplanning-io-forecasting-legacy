require 'rails_helper'

RSpec.describe WipHistory, type: :model do
  describe ".compute_history_for" do
    it "builds the wip history for the given project" do
      start_time = DateTime.parse('2015-01-01T12:00:00.000+0100')
      start_date = start_time.to_date
      epic_one = create(:epic, started: start_time, completed: start_time + 2.days)
      epic_two = create(:epic, started: epic_one.started + 1.day, completed: epic_one.completed + 1.day)
      project = create(:project, issues: [epic_one, epic_two])

      history = WipHistory.compute_history_for!(project)

      expect(simplify_history(project)).to eq [
                  { date: start_date, issue: epic_one },
                  { date: start_date + 1.day, issue: epic_one },
                  { date: start_date + 1.day, issue: epic_two },
                  { date: start_date + 2.day, issue: epic_two }
              ]
    end
  end

  def simplify_history(project)
    project.wip_histories.map do |history|
      { date: history.date, issue: history.issue }
    end
  end
end