class Project < ActiveRecord::Base
  validates :domain, presence: true
  validates :board_id, presence: true
  validates :name, presence: true
end
