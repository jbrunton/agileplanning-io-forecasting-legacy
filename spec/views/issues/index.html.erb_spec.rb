require 'rails_helper'

RSpec.describe "issues/index", type: :view do
  before(:each) do
    assign(:issues, [
      Issue.create!(
        :key => "Key",
        :summary => "Summary",
        :project_id => nil
      ),
      Issue.create!(
        :key => "Key",
        :summary => "Summary",
        :project_id => nil
      )
    ])
  end

  it "renders a list of issues" do
    render
    assert_select "tr>td", :text => "Key".to_s, :count => 2
    assert_select "tr>td", :text => "Summary".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
