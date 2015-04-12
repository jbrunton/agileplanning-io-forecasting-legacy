class Issue < ActiveRecord::Base
  belongs_to :project

  validates :key, presence: true
  validates :summary, presence: true
end
