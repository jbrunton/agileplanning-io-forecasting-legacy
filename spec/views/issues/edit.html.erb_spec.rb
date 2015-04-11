require 'rails_helper'

RSpec.describe "issues/edit", type: :view do
  before(:each) do
    @issue = assign(:issue, Issue.create!(
      :key => "MyString",
      :summary => "MyString",
      :project_id => nil
    ))
  end

  it "renders the edit issue form" do
    render

    assert_select "form[action=?][method=?]", issue_path(@issue), "post" do

      assert_select "input#issue_key[name=?]", "issue[key]"

      assert_select "input#issue_summary[name=?]", "issue[summary]"

      assert_select "input#issue_project_id_id[name=?]", "issue[project_id_id]"
    end
  end
end
