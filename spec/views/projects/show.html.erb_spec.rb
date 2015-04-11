require 'rails_helper'

RSpec.describe "projects/show", type: :view do
  before(:each) do
    @project = assign(:project, Project.create!(
      :domain => "Domain",
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
