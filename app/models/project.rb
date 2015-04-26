class Project < ActiveRecord::Base
  has_many :issues
  has_many :wip_histories, through: :issues

  validates :domain, presence: true
  validates :board_id, presence: true
  validates :name, presence: true

  def epics
    issues.where(issue_type: 'Epic')
  end

  def self.compute_cycle_times_for(epic)
    raise 'Issue must be an epic.' unless epic.issue_type == 'Epic'

    started_dates = epic.issues.map{|issue| issue.started}.compact
    if started_dates.any?
      epic.started = started_dates.min
    end

    completed_dates = epic.issues.map{|issue| issue.completed}.compact
    unless completed_dates.length < epic.issues.length # i.e. no issues are incomplete
      epic.completed = completed_dates.max
    end
  end

  def compute_cycle_times!
    epics.each do |epic|
      Project.compute_cycle_times_for(epic)
      epic.save
    end
    save
  end
end
