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
    let(:issue_started) { DateTime.new(2001, 1, 1) }
    let(:issue) { create(:issue, started: issue_started, completed: issue_started + 1.day, story_points: '5') }
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

    it "orders story point sizes in ascending order" do
      dashboard.issues << create(:issue, story_points: 1)
      dashboard.issues << create(:issue, story_points: 2)

      expect(dashboard.size_partitions_for('Story')).to eq([1, 2, 5])
    end

    it "filters by date, if given a filter" do
      dashboard.issues << create(:issue, story_points: 2, started: issue_started + 2.days, completed: issue_started + 3.days)
      filter = ::Filters::DateFilter.new("1 Jan 2001-2 Jan 2001")

      expect(dashboard.size_partitions_for('Story', filter)).to eq([5])
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

  describe "#wip_at" do
    let(:date) { Date.new(2001, 1, 1) }

    context "if there were no stories in progress" do
      let(:dashboard) { create(:dashboard) }

      it "returns an empty list" do
        expect(dashboard.wip_at(date, 'Story')).to eq([])
      end
    end

    context "if the dashboard has a started issue on that date" do
      let(:story) { create(:issue, started: date - 1.hour) }
      let(:dashboard) { create(:dashboard, issues: [story]) }

      it "returns a list with the started issue" do
        expect(dashboard.wip_at(date, 'Story')).to eq([story])
      end
    end

    context "if the dashboard has a completed issue before that date" do
      let(:story) { create(:issue, started: date - 2.hour, completed: date - 1.hour) }
      let(:dashboard) { create(:dashboard, issues: [story]) }

      it "does not include that issue" do
        expect(dashboard.wip_at(date, 'Story')).to eq([])
      end
    end

    context "if the dashboard has an issue that spans that date" do
      let(:story) { create(:issue, started: date - 1.hour, completed: date + 1.hour) }
      let(:dashboard) { create(:dashboard, issues: [story]) }

      it "does not include that issue" do
        expect(dashboard.wip_at(date, 'Story')).to eq([story])
      end
    end

    context "if the dashboard has an issue that starts on that date" do
      let(:story) { create(:issue, started: date, completed: date + 1.hour) }

      let(:dashboard) { create(:dashboard, issues: [story]) }

      it "includes the story on that issue" do
        expect(dashboard.wip_at(date, 'Story')).to eq([story])
      end
    end

    context "if the issue type is 'Story'" do
      let(:story) { create(:issue, started: date - 1.hour, completed: date + 1.hour) }
      let(:epic) { create(:epic, started: date - 1.hour, completed: date + 1.hour) }
      let(:dashboard) { create(:dashboard, issues: [story, epic]) }

      it "returns only stories" do
        expect(dashboard.wip_at(date, 'Story')).to eq([story])
      end
    end
  end

  describe "#wip_for" do
    let(:start_date) { Date.new(2001, 1, 1) }
    let(:middle_date) { Date.new(2001, 1, 2) }
    let(:end_date) { Date.new(2001, 1, 3) }
    let(:range) { DateRange.new(start_date, end_date) }

    context "if the range is empty" do
      let(:dashboard) { create(:dashboard) }

      it "returns an empty hash" do
        empty_range = DateRange.new(start_date, start_date)
        expect(dashboard.wip_for(empty_range, 'Story')).to eq({})
      end
    end

    context "if the dashboard has no issues" do
      let(:dashboard) { create(:dashboard) }

      it "returns an empty list for each date" do
        expect(dashboard.wip_for(range, 'Story')).to eq({
                    start_date => [],
                    middle_date => []
                })
      end
    end

    context "if the dashboard has a story completed in the range" do
      let(:story) {
        create(:issue,
            started: start_date + 1.hour,
            completed: end_date - 1.hour)
      }

      let(:dashboard) { create(:dashboard, issues: [story]) }

      it "returns the story in the WIP for that date" do
        expect(dashboard.wip_for(range, 'Story')).to eq({
                    start_date => [],
                    middle_date => [story]
                })
      end
    end

    context "if the dashboard has an epic completed in the range" do
      let(:epic) {
        create(:epic,
            started: start_date + 1.hour,
            completed: end_date - 1.hour)
      }

      let(:dashboard) { create(:dashboard, issues: [epic]) }

      it "returns the epic in the WIP for that date" do
        expect(dashboard.wip_for(range, 'Epic')).to eq({
                    start_date => [],
                    middle_date => [epic]
                })
      end
    end
  end

  describe "#wip_history" do
    context "if the dashboard has no issues" do
      let(:dashboard) { create(:dashboard) }

      it "returns an empty hash" do
        expect(dashboard.wip_history('Story')).to eq({})
      end
    end

    context "if the dashboard has an issue" do
      let(:start_date) { Date.new(2001, 1, 1) }
      let(:middle_date) { start_date + 1.day }
      let(:now) { start_date + 2.days }
      let(:story) { create(:issue, started: start_date, completed: start_date + 1.day) }
      let(:dashboard) { create(:dashboard, issues: [story]) }

      it "returns all WIP values between the start date and now" do
        Timecop.freeze(now) do
          expect(dashboard.wip_history('Story')).to eq({
                      start_date => [story],
                      middle_date => []
                  })
        end
      end
    end
  end
end
