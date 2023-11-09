class User < ApplicationRecord
  audited

  has_many :tasks, dependent: :destroy
  has_many :task_assigns, dependent: :destroy
  has_many :assigned_tasks, through: :task_assigns, source: :task

  has_associated_audits

  validates :name, presence: true
end
