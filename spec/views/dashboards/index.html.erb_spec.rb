require 'rails_helper'

RSpec.describe "dashboards/index", type: :view do
  before(:each) do
    assign(:domain, create(:domain, last_synced: DateTime.now))
    assign(:dashboards, [
      Dashboard.create!(
        :domain => create(:domain, domain: 'Domain'),
        :board_id => 1,
        :name => "Some Dashboard"
      ),
      Dashboard.create!(
        :domain => create(:domain, domain: 'Domain'),
        :board_id => 1,
        :name => "Another Dashboard"
      )
    ])
  end

  it "has a search input" do
    render
    assert_select "input#search-text", :count => 1
  end
end
