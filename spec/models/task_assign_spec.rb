require 'rails_helper'

RSpec.describe TaskAssign, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:task) }
end
