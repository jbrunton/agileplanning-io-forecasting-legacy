FactoryGirl.define do
  factory :issue do
    sequence(:key) { |k| "DEMO-#{k}" }
    sequence(:summary) { |k| "Issue #{k}" }
    project
  end
end