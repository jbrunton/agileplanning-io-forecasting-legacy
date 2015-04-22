require 'rails_helper'

RSpec.describe Jira::IssueBuilder do
  describe "#build" do
    let(:json) {
      <<-END
      {
        "key": "DEMO-101",
        "fields": {
          "summary": "Some Issue",
          "issuetype": {
            "name": "Story"
          },
          "customfield_10008": "EPIC-KEY"
        },
        "changelog": {
          "histories": [
            {
              "created": "2015-03-05T10:30:00.000+0100",
              "items": [
                {
                  "field": "status",
                  "fromString": "To Do",
                  "toString": "In Progress"
                }
              ]
            },
            {
              "created": "2015-03-10T10:30:00.000+0100",
              "items": [
                {
                  "field": "status",
                  "fromString": "In Progress",
                  "toString": "Done"
                }
              ]
            }
          ]
        }
      }
      END
    }

    let(:issue) { Jira::IssueBuilder.new(JSON.parse(json)).build }

    it "sets the key" do
      expect(issue.key).to eq('DEMO-101')
    end

    it "sets the summary" do
      expect(issue.summary).to eq('Some Issue')
    end

    it "sets the issue_type" do
      expect(issue.issue_type).to eq('Story')
    end

    it "sets the epic" do
      expect(issue.epic_key).to eq('EPIC-KEY')
    end

    context "if the issue_type is 'epic'" do
      let(:json) {
        <<-END
        {
          "key": "DEMO-101",
          "fields": {
            "summary": "Some Issue",
            "issuetype": {
              "name": "Epic"
            }
          },
          "changelog": {
            "histories": [
              {
                "created": "2015-03-05T10:30:00.000+0100",
                "items": [
                  {
                    "field": "status",
                    "fromString": "To Do",
                    "toString": "In Progress"
                  }
                ]
              },
              {
                "created": "2015-03-10T10:30:00.000+0100",
                "items": [
                  {
                    "field": "status",
                    "fromString": "In Progress",
                    "toString": "Done"
                  }
                ]
              }
            ]
          }
        }
        END
      }

      it "sets the started and comleted dates to nil" do
        issue = Jira::IssueBuilder.new(JSON.parse(json)).build
        expect(issue.started).to be_nil
        expect(issue.completed).to be_nil
      end
    end

    context "otherwise" do
      it "computes the started date" do
        expected_time = DateTime.parse("2015-03-05T10:30:00.000+0100")
        expect(issue.started).to eq(expected_time)
      end

      it "computes the completed date" do
        expected_time = DateTime.parse("2015-03-10T10:30:00.000+0100")
        expect(issue.completed).to eq(expected_time)
      end
    end
  end
end