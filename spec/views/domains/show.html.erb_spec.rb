require 'rails_helper'

RSpec.describe "domains/show", type: :view do
  before(:each) do
    @domain = assign(:domain, Domain.create!(
      :name => "Name",
      :domain => "Domain"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Domain/)
  end
end
