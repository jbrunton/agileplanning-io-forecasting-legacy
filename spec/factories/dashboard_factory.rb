FactoryGirl.define do
  factory :dashboard do
    domain
    sequence(:board_id) { |k| "Board #{k}" }
    sequence(:name) { |k| "Dashboard #{k}" }
  end
end