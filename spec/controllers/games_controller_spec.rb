require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:game) { create(:game) }
  let(:player1) { create(:player1) }
  let(:player2) { create(:player2) }
  let(:player3) { create(:player3) }
  let(:game_with_players) { game.add_player(player1); game.add_player(player2); game }
  let(:current_player) { game_with_players.player_game_states[0].player }

  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
    sign_in current_player
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #incomplete' do
    it 'returns http success' do
      get :incomplete
      expect(response).to have_http_status(:success)
    end

    it 'includes player game states' do
      get :incomplete
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an_instance_of Array
      expect(json_response.count).to eq 1
      expect(json_response[0]).to be_an_instance_of Hash
      game_states = json_response[0]['player_game_states']
      expect(game_states).to be_an_instance_of Array
      expect(game_states.count).to eq 2
      game_states.each do |game_state|
        expect(game_state['game_id']).to be_an_instance_of Fixnum
        expect(game_state['player_id']).to be_an_instance_of Fixnum
        expect(game_state['battle_grid']).to be_an_instance_of Array
        expect(game_state['tracking_grid']).to be_an_instance_of Array
      end
    end
  end

  describe 'GET #show' do
    it 'provides current players game state' do
      get :show, id: game_with_players.id
      expect(response).to have_http_status(:success)
      player_game_state = JSON.parse(response.body)
      expect(player_game_state).to be_an_instance_of Hash
      expect(player_game_state['player_id']).to eq current_player.id
      expect(player_game_state['battle_grid']).to be_an_instance_of Array
      expect(player_game_state['tracking_grid']).to be_an_instance_of Array
    end

    it 'includes associated game' do
      get :show, id: game_with_players.id
      player_game_state = JSON.parse(response.body)
      expect(player_game_state).to be_an_instance_of Hash
      game = player_game_state['game']
      expect(game).to be_an_instance_of Hash
      expect(game['id']).to eq game_with_players.id
    end

    it 'include associated player' do
      get :show, id: game_with_players.id
      player_game_state = JSON.parse(response.body)
      expect(player_game_state).to be_an_instance_of Hash
      player = player_game_state['player']
      expect(player['id']).to eq current_player.id
    end
  end

  describe 'POST #create' do
    it 'creates new game with current player associated' do
      post :create
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to_not be_nil
      expect(json_response['created_at']).to_not be_nil
      expect(json_response['updated_at']).to_not be_nil
      expect(json_response['startDate']).to_not be_nil
      expect(json_response['startDateUnixTimestamp']).to_not be_nil
      expect(json_response['status']).to eq 'pending'
      expect(json_response['player_game_states']).to be_an_instance_of Array
      expect(json_response['player_game_states'][0]['id']).to_not be_nil
      expect(json_response['player_game_states'][0]['game_id']).to eq json_response['id']
      expect(json_response['player_game_states'][0]['player_id']).to be_an_instance_of Fixnum
      expect(json_response['player_game_states'][0]['created_at']).to_not be_nil
      expect(json_response['player_game_states'][0]['updated_at']).to_not be_nil
    end
  end

  describe 'PUT #end' do
    it 'returns error if user not in game' do
      game_with_players.player_game_states[0].destroy
      put :end, id: game_with_players.id
      expect(response).to have_http_status(:forbidden)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq "Only players in the game may end the game"
    end

    it 'completes game' do
      put :end, id: game_with_players.id
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['status']).to eq 'complete'
    end
  end

  describe 'PUT #join' do
    it 'returns error if game does not have space for another player' do
      game_with_players.player_game_states[0].destroy # remove self from game
      game_with_players.add_player(player3) # add player3 as second player
      put :join, id: game_with_players.id
      expect(response).to have_http_status(:forbidden)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq "This game already has 2 players"
    end

    it 'adds player to game' do
      game_with_players.player_game_states[0].destroy # remove self from game
      put :join, id: game_with_players.id
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
    end
  end

  describe 'PUT #fire' do
    it 'returns error if not players turn' do
      game.end_current_turn
      put :fire, id: game_with_players.id, x: 2, y: 3
      expect(response).to have_http_status(:forbidden)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq "It is not your turn"
    end

    it 'ends current turn' do
      put :fire, id: game_with_players.id, x: 6, y: 8
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
    end
  end

end
