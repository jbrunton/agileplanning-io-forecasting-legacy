require 'rails_helper'

RSpec.describe "dashboards/edit", type: :view do
  before(:each) do
    @dashboard = assign(:dashboard, Dashboard.create!(
      :domain => "MyString",
      :board_id => "MyString",
      :name => "MyString"
    ))
  end

  it "renders the edit dashboard form" do
    render

    assert_select "form[action=?][method=?]", dashboard_path(@dashboard), "post" do

      assert_select "input#dashboard_domain[name=?]", "dashboard[domain]"

      assert_select "input#dashboard_board_id[name=?]", "dashboard[board_id]"

      assert_select "input#dashboard_name[name=?]", "dashboard[name]"
    end
  end
end
