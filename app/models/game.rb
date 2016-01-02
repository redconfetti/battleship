class Game < ActiveRecord::Base
  scope :incomplete, -> { where.not(status: 'complete') }

  has_many :player_game_states, dependent: :destroy
  has_many :players, through: :player_game_states

  def self.create_with_associated_player(player)
    game = Game.create
    game.add_player(player)
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

  def is_player?(player)
    players.include?(player)
  end

  def add_player(player)
    player_game_states.create(player: player)
    update(status: 'playing') if players.count == 2
  end
end
