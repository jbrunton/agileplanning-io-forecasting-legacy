require 'rails_helper'

RSpec.describe "projects/edit", type: :view do
  before(:each) do
    @project = assign(:project, Project.create!(
      :domain => "MyString",
      :board_id => "MyString",
      :name => "MyString"
    ))
  end

  it "renders the edit project form" do
    render

    assert_select "form[action=?][method=?]", project_path(@project), "post" do

      assert_select "input#project_domain[name=?]", "project[domain]"

      assert_select "input#project_board_id[name=?]", "project[board_id]"

      assert_select "input#project_name[name=?]", "project[name]"
    end
  end
end
