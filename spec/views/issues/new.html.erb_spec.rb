require 'rails_helper'

RSpec.describe "issues/new", type: :view do
  before(:each) do
    assign(:issue, Issue.new(
      :key => "MyString",
      :summary => "MyString",
      :project_id => nil
    ))
  end

  it "renders new issue form" do
    render

    assert_select "form[action=?][method=?]", issues_path, "post" do

      assert_select "input#issue_key[name=?]", "issue[key]"

      assert_select "input#issue_summary[name=?]", "issue[summary]"

      assert_select "input#issue_project_id_id[name=?]", "issue[project_id_id]"
    end
  end
end
