class GamesController < ApplicationController
  before_action :authenticate_player!, only: [:create]

  def index
    games = Game.all
    respond_to do |format|
      format.json { render json: games }
    end
  end

  def pending
    pending_games = Game.pending
    respond_to do |format|
      format.json { render json: pending_games }
    end
  end

  def create
    new_game = Game.create_with_associated_player(current_player)
    respond_to do |format|
      format.json { render json: new_game.to_json(:include => :player_game_states) }
    end
  end
end
