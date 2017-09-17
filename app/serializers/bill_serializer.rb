# == Schema Information
#
# Table name: bills
#
#  id              :integer          not null, primary key
#  meal_id         :integer          not null
#  resident_id     :integer          not null
#  community_id    :integer          not null
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("USD"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_bills_on_community_id             (community_id)
#  index_bills_on_meal_id                  (meal_id)
#  index_bills_on_meal_id_and_resident_id  (meal_id,resident_id) UNIQUE
#  index_bills_on_resident_id              (resident_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (meal_id => meals.id)
#  fk_rails_...  (resident_id => residents.id)
#

class BillSerializer < ActiveModel::Serializer
  include ApplicationHelper

  attributes :title,
             :start,
             :url,
             :description

  def title
    object.amount_cents == 0 && object.meal.date < Date.today ?
      "#{resident_name_helper(object.resident.name)}*" :
      "#{resident_name_helper(object.resident.name)}"

  end

  def start
    object.meal.date
  end

  def url
    "/meals/#{object.meal_id}/edit"
  end

  def description
    "Unit #{object.resident.unit.name}"
  end
end
