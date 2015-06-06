FactoryGirl.define do
  factory :issue do
    sequence(:key) { |k| "DEMO-#{k}" }
    sequence(:summary) { |k| "Issue #{k}" }
    issue_type 'Story'
    project

    factory :epic do
      sequence(:summary) { |k| "Epic #{k}" }
      issue_type 'Epic'
    end

    trait :started do
      sequence(:started) { |k| DateTime.new(2001, 1, 1) + k.days }
    end

    trait :completed do
      started
      sequence(:completed) do |k|
        started + (cycle_time ? cycle_time.days : k.days)
      end
    end

    transient do
      cycle_time false
      small false
      medium false
      large false
    end

    after(:build) do |issue, evaluator|
      issue.summary = "{issue.summary} [S]" if issue.size.nil? && evaluator.small
      issue.summary = "{issue.summary} [M]" if issue.size.nil? && evaluator.medium
      issue.summary = "{issue.summary} [L]" if issue.size.nil? && evaluator.large
    end
  end
end