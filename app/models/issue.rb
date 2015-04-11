class Issue < ActiveRecord::Base
  belongs_to :project_id

  validates :key, presence: true
  validates :summary, presence: true
end
