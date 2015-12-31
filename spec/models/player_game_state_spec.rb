require 'rails_helper'

RSpec.describe PlayerGameState, type: :model do
  let(:game)                { Game.create(created_at: '2015-01-26 04:15:32') }
  let(:player1)             { Player.create(email: 'johndoe@example.com', password: 'someP@$$word') }
  let(:player2)             { Player.create(email: 'jane@example.com', password: '$3cr3tP@$$w0rD') }
  let(:player3)             { Player.create(email: 'killroy@example.com', password: 'wuzhere') }
  let(:player1_game_state)  { PlayerGameState.create(game: game, player: player1) }
  let(:player2_game_state)  { PlayerGameState.create(game: game, player: player2) }
  subject { player1_game_state }

  describe ".for_game" do
    it 'returns PlayerGameStates for game' do
      subject # establish game with player 1
      player2_game_state # add player 2
      result = PlayerGameState.for_game(game)
      expect(result).to be_an_instance_of PlayerGameState::ActiveRecord_Relation
      expect(result.count).to eq 2
    end
  end

  it 'belongs to game' do
    result = subject.game
    expect(result).to be_an_instance_of Game
    expect(result.created_at).to eq '2015-01-26 04:15:32'
  end

  it 'belongs to player' do
    result = subject.player
    expect(result).to be_an_instance_of Player
    expect(result.email).to eq 'johndoe@example.com'
  end

  describe 'validations' do
    before(:each) { subject } # establish game with player 1

    it 'allows second player in game' do
      player2_game_state = PlayerGameState.new(game: game, player: player2)
      expect(player2_game_state.valid?).to eq true
      expect(player2_game_state.errors).to_not have_key(:game)
    end

    it 'prevents more than two players in game' do
      player2_game_state # add player 2
      player3_game_state = PlayerGameState.new(game: game, player: player3)
      expect(player3_game_state.valid?).to eq false
      expect(player3_game_state.errors).to have_key(:game)
    end
  end
end
