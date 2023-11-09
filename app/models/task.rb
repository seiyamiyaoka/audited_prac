class Task < ApplicationRecord
  belongs_to :user
  audited associated_with: :user

  validates :name, presence: true
end
