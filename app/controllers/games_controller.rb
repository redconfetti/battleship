class GamesController < ApplicationController
  before_action :authenticate_player!

  # GET /games.json
  def index
    games = Game.all
    respond_to do |format|
      format.json { render json: games }
    end
  end

  # GET /games/pending.json
  def pending
    pending_games = Game.includes(:player_game_states).pending
    respond_to do |format|
      format.json { render json: pending_games.to_json(:include => :player_game_states) }
    end
  end

  # GET /games/:id.json
  def show
    game = Game.includes(player_game_states: [:player]).find(params[:id])
    game_associations = {
      :player_game_states => {
        :include=> :player
      }
    }
    respond_to do |format|
      format.json { render json: game.to_json(:include => game_associations) }
    end
  end

  # POST /games.json
  def create
    new_game = Game.create_with_associated_player(current_player)
    respond_to do |format|
      format.json { render json: new_game.to_json(:include => :player_game_states) }
    end
  end

  # PUT /games/:id/end.json
  def end
    game = Game.find(params[:id])
    game.complete
    respond_to do |format|
      format.json { render json: game.to_json(:include => :player_game_states) }
    end
  end
end
