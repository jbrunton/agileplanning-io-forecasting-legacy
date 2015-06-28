FactoryGirl.define do
  factory :dashboard do
    domain 'http://www.example.com'
    sequence(:board_id) { |k| "Board #{k}" }
    sequence(:name) { |k| "Dashboard #{k}" }
  end
end