class Project < ActiveRecord::Base
  has_many :issues

  validates :domain, presence: true
  validates :board_id, presence: true
  validates :name, presence: true
end
