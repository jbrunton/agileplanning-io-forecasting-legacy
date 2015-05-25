class Project < ActiveRecord::Base
  has_many :issues
  has_many :wip_histories, through: :issues

  validates :domain, presence: true
  validates :board_id, presence: true
  validates :name, presence: true

  def epics
    issues.where(issue_type: 'Epic')
  end

  def stories
    issues.where("issue_type <> 'Epic' AND epic_key IS NOT NULL")
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
      Project.compute_cycle_times_for(epic)
      epic.save
    end
    save
  end

  def compute_sizes!
    sorted_epics = epics.
        select{ |epic| epic.cycle_time }.
        sort_by{ |epic| epic.cycle_time }

    incomplete_epics = epics.
        select{ |epic| epic.cycle_time.nil? }

    quartile_size = sorted_epics.length / 4
    interquartile_size = sorted_epics.length - quartile_size * 2

    first_quartile = sorted_epics.take(quartile_size)
    interquartile = sorted_epics.drop(quartile_size).take(interquartile_size)
    last_quartile = sorted_epics.drop(quartile_size + interquartile_size)

    {first_quartile => 'S', interquartile => 'M', last_quartile => 'L', incomplete_epics => nil}.each do |epics, size|
      epics.each do |epic|
        size_match = /\[(S|M|L)\]/.match(epic.summary)
        epic.size = size_match[1] unless size_match.nil?
        epic.size = size if epic.size.nil?
        epic.save
      end
    end
  end

  def complete_wip_history
    history_array = wip_histories.
        group_by{ |history| history.date }.
        map{ |date, histories| [date, histories.map{ |history| history.issue }] }.
        sort

    history = history_array.to_h

    DateRange.new(history_array.first[0], DateTime.now.to_date).to_a.each do |date|
      if history[date].nil?
        history[date] = date > history_array.last[0] ?
            history_array.last[1] :
            []
      end
    end

    history.sort.to_h
  end

end
