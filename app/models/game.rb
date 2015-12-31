class Game < ActiveRecord::Base
  scope :pending, -> { where(status: 'pending') }

  def as_json(options = {})
    super().merge({
      'startDate' => self.created_at.strftime('%m/%d/%y %I:%M %p'),
      'startDateUnixTimestamp' => self.created_at.to_i
    })
  end
end
