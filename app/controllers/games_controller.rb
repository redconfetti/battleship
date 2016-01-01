class GamesController < ApplicationController
  before_action :authenticate_player!

  def index
    games = Game.all
    respond_to do |format|
      format.json { render json: games }
    end
  end

  def pending
    pending_games = Game.includes(:player_game_states).pending
    respond_to do |format|
      format.json { render json: pending_games.to_json(:include => :player_game_states) }
    end
  end

  def create
    new_game = Game.create_with_associated_player(current_player)
    respond_to do |format|
      format.json { render json: new_game.to_json(:include => :player_game_states) }
    end
  end
end
