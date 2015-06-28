require 'rails_helper'

RSpec.describe "dashboards/index", type: :view do
  before(:each) do
    assign(:dashboards, [
      Dashboard.create!(
        :domain => "Domain",
        :board_id => 1,
        :name => "Name"
      ),
      Dashboard.create!(
        :domain => "Domain",
        :board_id => 1,
        :name => "Name"
      )
    ])
  end

  it "renders a list of dashboards" do
    render
    assert_select "tr>td", :text => "Domain".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
