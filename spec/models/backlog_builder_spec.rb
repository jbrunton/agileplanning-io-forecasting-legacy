require 'rails_helper'

RSpec.describe Backlog do
  describe "#initialize" do
    it "initializes the backlog" do
      in_progress = [create(:issue)]
      upcoming = [create(:issue)]

      backlog = Backlog.new(in_progress, upcoming)

      expect(backlog.in_progress).to eq(in_progress)
      expect(backlog.upcoming).to eq(upcoming)
    end
  end

  context "Backlog.Builder" do
    describe "#build" do
      context "when the dashboard is empty" do
        let(:dashboard) { create(:dashboard) }

        it "returns an empty backlog" do
          backlog = Backlog::Builder.new(dashboard, 'Story').build

          expect(backlog.in_progress).to eq([])
          expect(backlog.upcoming).to eq([])
        end
      end

      context "when the dashboard has in progress and upcoming stories" do
        let(:completed) { create(:issue, :completed) }
        let(:in_progress) { create(:issue, :started) }
        let(:upcoming) { create(:issue) }

        let(:backlog) do
          dashboard = create(:dashboard, issues: [completed, in_progress, upcoming])
          Backlog::Builder.new(dashboard, 'Story').build
        end

        it "builds a backlog with the in progress issues" do
          expect(backlog.in_progress).to eq([in_progress])
        end

        it "builds a backlog with the upcoming issues" do
          expect(backlog.upcoming).to eq([upcoming])
        end
      end

      context "when the issue_type is 'Epic'" do
        let(:completed_epic) { create(:epic, :completed, epic_status: nil) }
        let(:done_epic) { create(:epic, :completed) }
        let(:in_progress_story) { create(:issue, :started) }
        let(:in_progress_epic) { create(:epic, :started) }
        let(:upcoming_story) { create(:issue) }
        let(:upcoming_epic) { create(:epic) }

        let(:backlog) do
          dashboard = create(:dashboard, issues: [
                  completed_epic, done_epic,
                  in_progress_story, in_progress_epic,
                  upcoming_story, upcoming_epic])
          Backlog::Builder.new(dashboard, 'Epic').build
        end

        it "returns epics on the backlog" do
          expect(backlog.in_progress).to eq([completed_epic, in_progress_epic])
          expect(backlog.upcoming).to eq([upcoming_epic])
        end
      end
    end
  end
end
