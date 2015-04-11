require 'rails_helper'

RSpec.describe "issues/show", type: :view do
  before(:each) do
    @issue = assign(:issue, Issue.create!(
      :key => "Key",
      :summary => "Summary",
      :project_id => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Key/)
    expect(rendered).to match(/Summary/)
    expect(rendered).to match(//)
  end
end
