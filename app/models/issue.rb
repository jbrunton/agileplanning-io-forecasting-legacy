class Issue < ActiveRecord::Base
  belongs_to :project

  belongs_to :epic, class_name: 'Issue', foreign_key: 'epic_key', primary_key: 'key'
  has_many :issues, class_name: 'Issue', foreign_key: 'epic_key', primary_key: 'key'

  validates :key, presence: true
  validates :summary, presence: true
end
