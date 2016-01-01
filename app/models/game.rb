class Game < ActiveRecord::Base
  scope :pending, -> { where(status: 'pending') }

  has_many :player_game_states
  has_many :players, through: :player_game_states

  def self.create_with_associated_player(player)
    game = Game.create
    game.player_game_states.create(player: player)
    game
  end

  def as_json(options = {})
    super(options).merge({
      'startDate' => self.created_at.strftime('%m/%d/%y %I:%M %p'),
      'startDateUnixTimestamp' => self.created_at.to_i
    })
  end

  def complete
    update(status: 'complete')
  end

end
