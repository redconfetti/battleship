class PlayerGameState < ActiveRecord::Base
  belongs_to :game
  belongs_to :player

  validate :limit_two_per_game

  # Limits to two players associated with game
  def limit_two_per_game
    if self.class.for_game(self.game_id).count > 1
      errors.add(:game, "Cannot add more than 2 players to a Game")
    end
  end

  def self.for_game(game_id)
    where(game_id: game_id)
  end
end
