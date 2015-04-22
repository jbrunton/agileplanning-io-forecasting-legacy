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
end
