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

  #####################
  # Associations

  def current_player
    Player.where(id: current_player_id).first
  end

  def current_target
    return nil unless current_player
    players.where.not(id: current_player.id).first
  end

  def player_state(player)
    state = player_game_states.where(player_id: player.id).first
    raise ArgumentError, "Player #{player.id} is not present in this game" unless state
    state
  end

  #####################
  # State Checks

  def is_player?(player)
    player_game_states.exists?(player_id: player.id)
  end

  def is_turn?(player)
    return false unless current = current_player
    current.id == player.id
  end

  #####################
  # Actions

  def add_player(player)
    player_game_states.create(player: player)
    update(status: 'playing') if players.count == 2
    update(current_player_id: player.id) if current_player == nil
  end

  def complete
    update(status: 'complete')
  end

  def end_current_turn
    update(current_player_id: current_target.id)
    player_game_states.each do |game_state|
      game_state.publish_update
    end
  end

end
