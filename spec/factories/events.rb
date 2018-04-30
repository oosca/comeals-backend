# == Schema Information
#
# Table name: events
#
#  id           :bigint(8)        not null, primary key
#  title        :string           not null
#  description  :string           default(""), not null
#  start_date   :datetime         not null
#  end_date     :datetime
#  allday       :boolean          default(FALSE), not null
#  community_id :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_events_on_community_id  (community_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#

FactoryBot.define do
  factory :event do
    title "Maintenance Committee Meeting"
    start_date "2017-09-13 20:00:00"
    end_date "2017-09-13 21:00:00"
    allday false
    community
  end
end
