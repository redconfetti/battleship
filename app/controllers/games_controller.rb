class GamesController < ApplicationController
  before_action :authenticate_player!

  # GET /games.json
  def index
    games = Game.all
    respond_to do |format|
      format.json { render json: games }
    end
  end

  # GET /games/incomplete.json
  def incomplete
    incomplete_games = Game.includes(:player_game_states).incomplete
    respond_to do |format|
      format.json { render json: incomplete_games.to_json(:include => :player_game_states) }
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
    raise Exceptions::Forbidden, "Only players in the game may end the game" unless game.is_player?(current_player)
    game.complete
    respond_to do |format|
      format.json { render json: game.to_json(:include => :player_game_states) }
    end
  end

  # PUT /games/:id/join.json
  def join
    game = Game.find(params[:id])
    raise Exceptions::Forbidden, "This game already has 2 players" unless game.players.count < 2
    game.add_player(current_player)
    respond_to do |format|
      format.json { render json: game.to_json }
    end
  end
end
