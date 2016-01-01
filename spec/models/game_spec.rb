require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:player1)           { create(:player1) }
  let(:game_with_players) { create(:game_with_players) }
  subject                 { create(:game) }

  describe '.create_with_associated_player' do
    it 'creates game with specified player associated' do
      result = Game.create_with_associated_player(player1)
      player_game_states = result.player_game_states
      expect(result).to be_an_instance_of Game
      expect(player_game_states.count).to eq 1
      expect(player_game_states[0].player_id).to eq player1.id
      expect(player_game_states[0].player.email).to eq 'johndoe@example.com'
    end
  end

  describe '#players' do
    it 'returns players associated through PlayerGameStates' do
      result = game_with_players.players
      expect(result).to be_an_instance_of Player::ActiveRecord_Associations_CollectionProxy
      expect(result.count).to eq 2
      result.each do |player|
        expect(player).to be_an_instance_of Player
      end
    end
  end

  describe '#as_json' do
    it 'returns json representation' do
      result = subject.as_json
      expect(result).to be_an_instance_of Hash
    end

    it 'includes start date in json' do
      result = subject.as_json
      expect(result['startDate']).to eq '01/26/15 04:15 AM'
    end

    it 'includes start date timestamp in json' do
      result = subject.as_json
      expect(result['startDateUnixTimestamp']).to eq 1422245732
    end
  end

  describe '#complete' do
    it 'updates game status as complete' do
      subject.complete
      expect(subject.reload.status).to eq 'complete'
    end
  end
end
