require 'rails_helper'

RSpec.describe "domains/new", type: :view do
  before(:each) do
    assign(:domain, Domain.new(
      :name => "MyString",
      :domain => "MyString"
    ))
  end

  it "renders new domain form" do
    render

    assert_select "form[action=?][method=?]", domains_path, "post" do

      assert_select "input#domain_name[name=?]", "domain[name]"

      assert_select "input#domain_domain[name=?]", "domain[domain]"
    end
  end
end
