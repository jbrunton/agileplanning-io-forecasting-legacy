FactoryGirl.define do
  factory :domain do
    sequence(:name) { |k| "Domain #{k}" }
    domain "www.example.com"
  end
end
