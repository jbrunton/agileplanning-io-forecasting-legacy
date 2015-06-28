require 'rails_helper'

RSpec.describe "dashboards/show", type: :view do
  before(:each) do
    dashboard = assign(:dashboard, Dashboard.create!(
      :domain => create(:domain),
      :board_id => "Board",
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Domain/)
    expect(rendered).to match(/Board/)
    expect(rendered).to match(/Name/)
  end
end
