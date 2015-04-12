require 'rails_helper'

RSpec.describe Jira::IssueBuilder do
  describe "#build" do
    let(:json) {
      <<-END
      {
        "key": "DEMO-101",
        "fields": {
          "summary": "Some Issue"
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
  end
end