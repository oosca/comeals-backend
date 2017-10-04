# == Schema Information
#
# Table name: meals
#
#  id                        :integer          not null, primary key
#  date                      :date             not null
#  cap                       :integer
#  meal_residents_count      :integer          default(0), not null
#  guests_count              :integer          default(0), not null
#  bills_count               :integer          default(0), not null
#  cost                      :integer          default(0), not null
#  meal_residents_multiplier :integer          default(0), not null
#  guests_multiplier         :integer          default(0), not null
#  description               :text             default(""), not null
#  max                       :integer
#  closed                    :boolean          default(FALSE), not null
#  community_id              :integer          not null
#  reconciliation_id         :integer
#  rotation_id               :integer
#  closed_at                 :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_meals_on_community_id       (community_id)
#  index_meals_on_reconciliation_id  (reconciliation_id)
#  index_meals_on_rotation_id        (rotation_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (reconciliation_id => reconciliations.id)
#  fk_rails_...  (rotation_id => rotations.id)
#

class Meal < ApplicationRecord
  audited
  has_associated_audits

  attr_accessor :socket_id

  scope :unreconciled, -> { where(reconciliation_id: nil) }

  belongs_to :community
  belongs_to :reconciliation, optional: true
  belongs_to :rotation, optional: true

  has_many :bills, dependent: :destroy
  has_many :cooks, through: :bills, source: :resident
  has_many :meal_residents, inverse_of: :meal, dependent: :destroy
  has_many :guests, inverse_of: :meal, dependent: :destroy
  has_many :hosts, through: :guests, source: :resident
  has_many :attendees, through: :meal_residents, source: :resident
  has_many :residents, through: :community

  validates :date, presence: true
  validates :community, presence: true
  validates :max, numericality: { greater_than_or_equal_to: :attendees_count, message: "Max can't be less than current number of attendees." }, allow_nil: true

  before_create :set_cap
  before_save :conditionally_set_max
  before_save :conditionally_set_closed_at
  after_touch :mark_related_residents_dirty

  accepts_nested_attributes_for :guests, allow_destroy: true, reject_if: proc { |attributes| attributes['name'].blank? }
  accepts_nested_attributes_for :bills, allow_destroy: true, reject_if: proc { |attributes| attributes['resident_id'].blank? }

  def cap
    read_attribute(:cap) || Float::INFINITY
  end

  def set_cap
    self.cap = community.cap
  end

  def conditionally_set_max
    self.max = nil if closed == false
  end

  def conditionally_set_closed_at
    self.closed_at = DateTime.now if closed == true && closed_was == false
    self.closed_at = nil if closed == false && closed_was == true
  end

  def mark_related_residents_dirty
    cooks.update_all(balance_is_dirty: true)
    attendees.update_all(balance_is_dirty: true)
    hosts.update_all(balance_is_dirty: true)
  end

  def trigger_pusher
    Pusher.trigger(
      "meal-#{id}",
      'update',
      { message: 'meal updated' },
      { socket_id: socket_id }
    )
    return true
  end

  # DERIVED DATA
  def multiplier
    meal_residents_multiplier + guests_multiplier
  end

  def attendees_count
    meal_residents_count + guests_count
  end

  def modified_cost
    bills.map(&:reimburseable_amount).inject(0, :+)
  end

  def unit_cost
    bills.map(&:unit_cost).inject(0, :+)
  end

  def collected
    unit_cost * multiplier
  end

  def subsidized?
    return false if multiplier == 0
    cost > max_cost
  end

  def reconciled?
    reconciliation_id.present?
  end

  # HELPERS
  def max_cost
    cap * multiplier
  end

  def self.create_templates(community_id, start_date, end_date, alternating_dinner_day, num_meals_created)
    # Are we finished?
    return num_meals_created if start_date >= end_date

    # Is it a holiday?
    if Meal.is_holiday(start_date)
      start_date += 24.hour
      return create_templates(community_id, start_date, end_date, alternating_dinner_day, num_meals_created)
    end

    # Is it a common dinner day?
    if [alternating_dinner_day, 2, 4].any? { |num| num == start_date.wday }
      # Flip if alternating dinner day
      if start_date.wday == alternating_dinner_day
        alternating_dinner_day = (alternating_dinner_day - 1) ** 2
      end

      community = Community.find(community_id)
      temp = Meal.new(date: start_date, cap: community.cap, community_id: community_id)
      if temp.save
        num_meals_created += 1
      else
        puts temp.errors.to_s
      end

      # If common dinner was on a Sunday, we
      # don't have dinner the next day
      start_date += 24.hour if start_date.wday == 0

      start_date += 24.hour
      return create_templates(community_id, start_date, end_date, alternating_dinner_day, num_meals_created)
    else
      start_date += 24.hour
      return create_templates(community_id, start_date, end_date, alternating_dinner_day, num_meals_created)
    end
  end

  def self.is_holiday(date)
    return true if Meal.is_thanksgiving(date) || Meal.is_christmas(date) || Meal.is_newyears(date)
    false
  end

  def self.is_thanksgiving(date)
    return false unless date.class == Date
    return false unless date.month == 11
    return false unless date.thursday?
    return false unless date.day >= 22 && date.day <= 28
    true
  end

  def self.is_christmas(date)
    return true if date.month == 12 && date.day == 25
    false
  end

  def self.is_newyears(date)
    return true if date.month == 1 && date.day == 1
    false
  end

end
