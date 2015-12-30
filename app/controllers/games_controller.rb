class GamesController < ApplicationController
  def index
    @games = Game.all
    respond_to do |format|
      format.json { render json: @games }
    end
  end

  def pending
    @pending_games = Game.pending
    respond_to do |format|
      format.json { render json: @pending_games }
    end
  end
end
