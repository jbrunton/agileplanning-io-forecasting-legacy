require 'rails_helper'

RSpec.describe "dashboards/new", type: :view do
  before(:each) do
    assign(:dashboard, Dashboard.new(
      :domain => "MyString",
      :board_id => "MyString",
      :name => "MyString"
    ))
  end

  it "renders new dashboard form" do
    render

    assert_select "form[action=?][method=?]", projects_path, "post" do

      assert_select "input#project_domain[name=?]", "dashboard[domain]"

      assert_select "input#project_board_id[name=?]", "dashboard[board_id]"

      assert_select "input#project_name[name=?]", "dashboard[name]"
    end
  end
end
