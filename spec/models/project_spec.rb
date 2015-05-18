require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "#epics" do
    it "returns all the epics" do
      project = create(:project, issues: [create(:issue)])
      epic = create(:issue, issue_type: 'Epic', project: project)

      expect(project.epics).to eq([epic])
    end
  end

  describe ".compute_cycle_times_for" do
    it "throws an error unless the issue is an epic" do
      expect{
        Project.compute_cycle_times_for(create(:issue))
      }.to raise_error("Issue must be an epic.")
    end

    it "computes the started and completed dates" do
      epic = create(:issue, issue_type: 'Epic')
      epic.issues = [issue = create(:issue, :completed)]

      Project.compute_cycle_times_for(epic)

      expect(epic.started).to eq(issue.started)
      expect(epic.completed).to eq(issue.completed)
    end

    it "only sets the completed date if all issues are completed" do
      epic = create(:issue, issue_type: 'Epic')
      epic.issues = [create(:issue, :started)]

      Project.compute_cycle_times_for(epic)

      expect(epic.completed).to be_nil
    end
  end

  describe "#complete_wip_history" do
    it "returns wip histories grouped by date" do
      start_date = DateTime.new(2001, 1, 1)
      project = create(:project, issues: [
              build(:epic, started: start_date, completed: start_date + 1.day),
              build(:epic, started: start_date + 3.days)
          ])
      epic_one = project.issues[0]
      epic_two = project.issues[1]
      WipHistory.compute_history_for!(project)

      Timecop.freeze(start_date + 5.days)
      history = project.complete_wip_history

      expect(history).to eq({
                  start_date.to_date => [epic_one],
                  start_date.to_date + 1.days => [],
                  start_date.to_date + 2.days => [],
                  start_date.to_date + 3.days => [epic_two],
                  start_date.to_date + 4.days => [epic_two]
              })
    end
  end
end
