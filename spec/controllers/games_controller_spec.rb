require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:game_with_players)   { create(:game_with_players) }

  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
    sign_in game_with_players.player_game_states[0].player
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #pending' do
    it 'returns http success' do
      get :pending
      expect(response).to have_http_status(:success)
    end

    it 'includes player game states' do
      get :pending
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
    it 'returns game' do
      get :show, id: game_with_players.id
      expect(response).to have_http_status(:success)
      game = JSON.parse(response.body)
      expect(game).to be_an_instance_of Hash
      expect(game['id']).to eq game_with_players.id
    end

    it 'includes associated player game states' do
      get :show, id: game_with_players.id
      game = JSON.parse(response.body)
      expect(game).to be_an_instance_of Hash
      player_game_states = game['player_game_states']
      expect(player_game_states).to be_an_instance_of Array
      player_game_states.each do |game_state|
        expect(game_state['battle_grid']).to be_an_instance_of Array
        expect(game_state['tracking_grid']).to be_an_instance_of Array
      end
    end

    it 'associated player game states include players' do
      get :show, id: game_with_players.id
      game = JSON.parse(response.body)
      player_game_states = game['player_game_states']
      player_game_states.each do |game_state|
        expect(game_state['player']).to be_an_instance_of Hash
        expect(game_state['player']['id']).to be_an_instance_of Fixnum
      end
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
    it 'completes game' do
      put :end, id: game_with_players.id
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['status']).to eq 'complete'
    end
  end

end
