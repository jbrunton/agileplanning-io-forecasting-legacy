require 'rails_helper'

RSpec.describe Dashboard, type: :model do
  describe "#epics" do
    it "returns all the epics" do
      dashboard = create(:dashboard, issues: [create(:issue)])
      epic = create(:issue, issue_type: 'Epic', dashboard: dashboard)

      expect(dashboard.epics).to eq([epic])
    end
  end

  describe "#size_partitions_for" do
    let(:issue) { create(:issue, story_points: '5') }
    let(:epic) { create(:epic, summary: 'Some Epic [M]') }
    let(:dashboard) { dashboard = create(:dashboard, issues: [issue, epic]) }

    it "returns the size partitions for issues" do
      expect(dashboard.size_partitions_for('Story')).to eq([issue.size])
    end

    it "returns the size partitions for epics" do
      expect(dashboard.size_partitions_for('Epic')).to eq([epic.size])
    end

    it "returns a unique list without nils" do
      dashboard.issues << create(:issue)
      dashboard.issues << create(:issue, story_points: '5')
      dashboard.reload

      expect(dashboard.size_partitions_for('Story')).to eq([issue.size])
    end
  end

  describe ".compute_cycle_times_for" do
    it "throws an error unless the issue is an epic" do
      expect{
        Dashboard.compute_cycle_times_for(create(:issue))
      }.to raise_error("Issue must be an epic.")
    end

    it "computes the started and completed dates" do
      epic = create(:epic, epic_status: 'Done')
      epic.issues = [issue = create(:issue, :completed)]

      Dashboard.compute_cycle_times_for(epic)

      expect(epic.started).to eq(issue.started)
      expect(epic.completed).to eq(issue.completed)
    end

    it "only sets the completed date if all issues are completed and the status is 'Done'" do
      epic = create(:issue, issue_type: 'Epic')
      epic.issues = [create(:issue, :started)]

      Dashboard.compute_cycle_times_for(epic)

      expect(epic.completed).to be_nil
    end

    it "leaves the completed date unset if the issues are completed but the status is 'To Do'"

    it "leaves the completed date unset if the status is 'Done' but the stories aren't completed"

  end

  describe "#complete_wip_history" do
    let(:start_date) { DateTime.new(2001, 1, 1) }
    let(:dashboard) { create(:dashboard, issues: [
            build(:epic, started: start_date, completed: start_date + 1.day),
            build(:epic, started: start_date + 3.days),
            build(:issue, started: start_date, completed: start_date + 1.day)
        ]) }

    let(:epic_one) { dashboard.issues[0] }
    let(:epic_two) { dashboard.issues[1] }
    let(:story) { dashboard.issues[2] }

    before(:each) do
      WipHistory.compute_history_for!(dashboard)
      Timecop.freeze(start_date + 5.days)
    end

    it "returns wip histories for epics grouped by date" do
      history = dashboard.complete_wip_history('Epic')

      expect(history).to eq({
                  start_date.to_date => [epic_one],
                  start_date.to_date + 1.days => [],
                  start_date.to_date + 2.days => [],
                  start_date.to_date + 3.days => [epic_two],
                  start_date.to_date + 4.days => [epic_two]
              })
    end

    it "returns wip histories for stories grouped by date" do
      history = dashboard.complete_wip_history('Story')

      expect(history).to eq({
                  start_date.to_date => [story],
                  start_date.to_date + 1.days => [],
                  start_date.to_date + 2.days => [],
                  start_date.to_date + 3.days => [],
                  start_date.to_date + 4.days => []
              })
    end
  end
end
