class PlayerGameState < ActiveRecord::Base
  belongs_to :game
  belongs_to :player

  validate :limit_two_per_game

  serialize :battle_grid, Hash
  serialize :tracking_grid, Hash

  before_create :init_grids

  def self.for_game(game_id)
    where(game_id: game_id)
  end

  # Limits to two players associated with game
  def limit_two_per_game
    if self.class.for_game(self.game_id).count > 1
      errors.add(:game, "Cannot add more than 2 players to a Game")
    end
  end

  def init_grids
    (0..9).to_a.each do |x|
      (0..9).to_a.each do |y|
        tracking_grid["#{x},#{y}"] = false
        battle_grid["#{x},#{y}"] = false
      end
    end
  end

end
