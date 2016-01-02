require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:game_with_players)   { create(:game_with_players) }
  subject                   { game_with_players.players[0] }

  describe '#active_game' do
    it 'returns players active game' do
      result = subject.active_game
      expect(result).to be_an_instance_of Game
    end
  end
end
