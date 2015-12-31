class CreatePlayerGameStates < ActiveRecord::Migration
  def change
    create_table :player_game_states do |t|
      t.references :game, index: true, foreign_key: true
      t.references :player, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
