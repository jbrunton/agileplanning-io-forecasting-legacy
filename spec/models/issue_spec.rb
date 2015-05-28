require 'rails_helper'

RSpec.describe Issue, type: :model do
  let(:project) { create(:project) }

  describe "#size" do
    context "if the epic has a t-shirt-size" do
      it "returns the size" do
        epic = create(:epic, summary: "Small Epic [S]", project: project)
        expect(epic.size).to eq('S')
      end
    end

    context "if the epic has no t-shirt-size" do
      it "returns nil" do
        epic = create(:epic, summary: "Unsized Epic", project: project)
        expect(epic.size).to be_nil
      end
    end
  end
end
