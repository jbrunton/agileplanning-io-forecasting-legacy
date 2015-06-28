require 'rails_helper'

RSpec.describe BacklogBuilder do
  describe "#build" do
    context "when the dashboard is empty" do
      let(:dashboard) { create(:dashboard) }

      it "returns an empty backlog" do
        builder = BacklogBuilder.new(dashboard, 'Story')
        expect(builder.build).to eq({
                    in_progress: [],
                    upcoming: []
                })
      end
    end

    context "when the dashboard has in progress and upcoming stories" do
      let(:completed) { create(:issue, :completed) }
      let(:in_progress) { create(:issue, :started) }
      let(:upcoming) { create(:issue) }

      let(:builder) do
        dashboard = create(:dashboard, issues: [completed, in_progress, upcoming])
        BacklogBuilder.new(dashboard, 'Story')
      end

      it "enumerates the in progress issues" do
        expect(builder.build[:in_progress]).to eq([in_progress])
      end

      it "enumerates the upcoming issues" do
        expect(builder.build[:upcoming]).to eq([upcoming])
      end
    end

    context "when the issue_type is 'Epic'" do
      let(:completed_epic) { create(:epic, :completed, epic_status: nil) }
      let(:done_epic) { create(:epic, :completed) }
      let(:in_progress_story) { create(:issue, :started) }
      let(:in_progress_epic) { create(:epic, :started) }
      let(:upcoming_story) { create(:issue) }
      let(:upcoming_epic) { create(:epic) }

      let(:builder) do
        dashboard = create(:dashboard, issues: [
                completed_epic, done_epic,
                in_progress_story, in_progress_epic,
                upcoming_story, upcoming_epic])
        BacklogBuilder.new(dashboard, 'Epic')
      end

      it "returns epics on the backlog" do
        expect(builder.build[:in_progress]).to eq([completed_epic, in_progress_epic])
        expect(builder.build[:upcoming]).to eq([upcoming_epic])
      end
    end
  end
end
