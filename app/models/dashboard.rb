class Dashboard < ActiveRecord::Base
  has_many :issues
  has_many :wip_histories, through: :issues
  belongs_to :domain

  validates :domain, presence: true
  validates :board_id, presence: true
  validates :name, presence: true

  def epics
    issues.of_type('Epic')
  end

  def self.compute_cycle_times_for(epic)
    raise 'Issue must be an epic.' unless epic.issue_type == 'Epic'

    started_dates = epic.issues.map{|issue| issue.started}.compact
    if started_dates.any?
      epic.started = started_dates.min
    end

    if epic.epic_status == 'Done'
      completed_dates = epic.issues.map{|issue| issue.completed}.compact
      unless completed_dates.length < epic.issues.length # i.e. no issues are incomplete
        epic.completed = completed_dates.max
      end
    end
  end

  def compute_cycle_times!
    epics.each do |epic|
      Dashboard.compute_cycle_times_for(epic)
      epic.save
    end
    save
  end

  def wip_at(date, issue_type)
    # convert to a time for comparisons, so that we include stories that finish on the same day
    time = date.to_datetime
    issues.of_type(issue_type).
        where('started <= :time AND (completed IS NULL OR completed > :time)', time: time)
  end

  def wip_for(date_range, issue_type)
    date_range.to_a.
        map { |date| [date, wip_at(date, issue_type)] }.
        to_h
  end

  def wip_history(issue_type)
    start_date = issues.of_type(issue_type).minimum('started')
    return {} if start_date.nil?
    date_range = DateRange.new(start_date.to_date, DateTime.now.to_date)
    wip_for(date_range, issue_type)
  end
end
