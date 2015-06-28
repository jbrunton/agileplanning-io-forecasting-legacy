# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

random = Random.new(0)

dashboard = Dashboard.create(domain: 'http://example.com', name: 'Example Board', board_id: 1)

COMPLETED_EPICS = 40
ACTIVE_EPICS = 3
UPCOMING_EPICS = 5
TOTAL_EPICS = COMPLETED_EPICS + ACTIVE_EPICS + UPCOMING_EPICS

count = 0

start_date = DateTime.now - (TOTAL_EPICS + 30).days

(1..TOTAL_EPICS).each do |k|
  count = count + 1

  epic = dashboard.issues.create(
      key: "DEMO-#{count}",
      summary: "Epic #{k}",
      dashboard: dashboard,
      issue_type: 'Epic',
      epic_status: k > COMPLETED_EPICS ? nil : 'Done'
  )

  (1..2 + random.rand(3)).each do |l|
    count = count + 1

    started = k > COMPLETED_EPICS + ACTIVE_EPICS ? nil : start_date + (5.0 * k + random.rand(5)).to_i.days
    completed = k > COMPLETED_EPICS ? nil : started + (1 + random.rand(15)).days

    dashboard.issues.create(
        key: "DEMO-#{count}",
        summary: "Issue #{count}",
        dashboard: dashboard,
        issue_type: 'Story',
        epic: epic,
        started: started,
        completed: completed
    )
  end
end

dashboard.compute_cycle_times!
WipHistory.compute_history_for!(dashboard)
