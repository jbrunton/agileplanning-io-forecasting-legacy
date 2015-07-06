class Issue < ActiveRecord::Base
  belongs_to :dashboard

  belongs_to :epic, class_name: 'Issue', foreign_key: 'epic_key', primary_key: 'key'
  has_many :issues, class_name: 'Issue', foreign_key: 'epic_key', primary_key: 'key'
  has_many :wip_histories

  validates :key, presence: true
  validates :summary, presence: true

  def cycle_time
    (completed - started) / 1.day unless started.nil? || completed.nil?
  end

  def completed?
    return epic_status == 'Done' if issue_type == 'Epic'
    !completed.nil?
  end

  def size
    size_match = /\[(S|M|L)\]/.match(summary) if issue_type == 'Epic'
    size_match[1] unless size_match.nil?
  end

  def self.of_type(issue_type)
    if issue_type == 'All'
      where("issue_type <> 'Epic'")
    else
      where("issue_type = ?", issue_type)
    end
  end
end
