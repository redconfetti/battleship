class Game < ActiveRecord::Base
  scope :incomplete, -> { where.not(status: 'complete') }

  has_many :player_game_states, dependent: :destroy
  has_many :players, through: :player_game_states

  belongs_to :winner, class_name: Player
  belongs_to :loser, class_name: Player

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

  ###########################
  # Channel Communication

  def trigger_update
    Pusher.trigger("game-#{id}", 'updated', to_json)
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
    trigger_update
  end

  def take_shot(player, enemy_x, enemy_y)
    raise ArgumentError, "Player #{player.id} is not present in this game" unless is_player?(player)
    raise ArgumentError, "Player #{player.id} cannot take a shot. It is not their turn" unless is_turn?(player)
    enemy_player_state = player_state(current_target)
    enemy_player_state.receive_shot(enemy_x, enemy_y)

    if enemy_player_state.reload.defeated?
      end_game(player, enemy_player_state.player)
    else
      end_current_turn
    end
  end

  def end_current_turn
    update(current_player_id: current_target.id)
    trigger_update
  end

  def end_game(winner, loser)
    update(winner: winner, loser: loser, status: 'complete')
    trigger_update
  end

end
