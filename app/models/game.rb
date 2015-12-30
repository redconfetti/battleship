class Game < ActiveRecord::Base
  scope :pending, -> { where(status: 'pending') }
end
