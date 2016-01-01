require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:player1) { create(:player1) }
  subject       { create(:game) }

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
end
