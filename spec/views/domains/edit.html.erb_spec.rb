require 'rails_helper'

RSpec.describe "domains/edit", type: :view do
  before(:each) do
    @domain = assign(:domain, Domain.create!(
      :name => "MyString",
      :domain => "MyString"
    ))
  end

  it "renders the edit domain form" do
    render

    assert_select "form[action=?][method=?]", domain_path(@domain), "post" do

      assert_select "input#domain_name[name=?]", "domain[name]"

      assert_select "input#domain_domain[name=?]", "domain[domain]"
    end
  end
end
