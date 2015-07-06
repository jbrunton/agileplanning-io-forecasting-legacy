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

  def stories
    issues.of_type('Story')
  end

  def all_issues
    issues.of_type('All')
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

  def complete_wip_history(issue_type)
    history_array = wip_histories.
        for_issue_type(issue_type).
        group_by{ |history| history.date }.
        map{ |date, histories| [date, histories.map{ |history| history.issue }] }.
        sort

    history = history_array.to_h

    DateRange.new(history_array.first[0], DateTime.now.to_date).to_a.each do |date|
      if history[date].nil?
        last_date = history_array.last[0]
        if date > last_date
          last_issues = history_array.last[1]
          in_progress = last_issues.select{ |issue| issue.completed.nil? }
          history[date] = in_progress
        else
          history[date] = []
        end
      end
    end

    history.sort.to_h
  end

end
