class Issue < ActiveRecord::Base
  belongs_to :project

  belongs_to :epic, class_name: 'Issue', foreign_key: 'epic_key', primary_key: 'key'
  has_many :issues, class_name: 'Issue', foreign_key: 'epic_key', primary_key: 'key'
  has_many :wip_histories

  validates :key, presence: true
  validates :summary, presence: true

  def cycle_time
    (completed - started) / 1.day if completed?
  end

  def completed?
    !completed.nil? && (issue_type != 'Epic' || epic_status == 'Done')
  end

  def size
    size_match = /\[(S|M|L)\]/.match(summary) if issue_type == 'Epic'
    size_match[1] unless size_match.nil?
  end
end
