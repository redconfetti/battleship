class AddGridsToPlayerGameState < ActiveRecord::Migration
  def change
    add_column :player_game_states, :battle_grid, :text
    add_column :player_game_states, :tracking_grid, :text
  end
end
