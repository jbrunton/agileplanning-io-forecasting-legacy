FactoryGirl.define do
  factory :project do
    domain 'http://www.example.com'
    sequence(:board_id) { |k| "Board #{k}" }
    sequence(:name) { |k| "Project #{k}" }
  end
end