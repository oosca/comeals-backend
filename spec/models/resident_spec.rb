# == Schema Information
#
# Table name: residents
#
#  id                   :integer          not null, primary key
#  name                 :string           not null
#  email                :string
#  community_id         :integer          not null
#  unit_id              :integer          not null
#  vegetarian           :boolean          default(FALSE), not null
#  bill_costs           :integer          default(0), not null
#  bills_count          :integer          default(0), not null
#  multiplier           :integer          default(2), not null
#  password_digest      :string           not null
#  reset_password_token :string
#  balance_is_dirty     :boolean          default(TRUE), not null
#  can_cook             :boolean          default(TRUE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  active               :boolean          default(TRUE), not null
#  birthday             :date             default(Mon, 01 Jan 1900), not null
#
# Indexes
#
#  index_residents_on_community_id           (community_id)
#  index_residents_on_email                  (email) UNIQUE
#  index_residents_on_name_and_community_id  (name,community_id) UNIQUE
#  index_residents_on_reset_password_token   (reset_password_token) UNIQUE
#  index_residents_on_unit_id                (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (unit_id => units.id)
#

require 'rails_helper'

RSpec.describe Resident, type: :model do
  it 'has the correct balance' do
    # Scenario #1: resident attends meal
    community = FactoryBot.create(:community)
    meal = FactoryBot.create(:meal, community_id: community.id)

    unit = FactoryBot.create(:unit, community_id: community.id)
    resident = FactoryBot.create(:resident, community_id: community.id)

    meal_resident = FactoryBot.create(:meal_resident, meal_id: meal.id, resident_id: resident.id, community_id: community.id)
    bill = FactoryBot.create(:bill, meal_id: meal.id, resident_id: resident.id, community_id: community.id)

    expect(resident.balance).to eq(0)
  end
end
