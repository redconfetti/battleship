require 'rails_helper'

RSpec.describe PlayerGameState, type: :model do
  let(:game)    { Game.create(created_at: '2015-01-26 04:15:32') }
  let(:player)  { Player.create(email: 'johndoe@example.com', password: '$3cr3tP@$$w0rD') }
  subject { PlayerGameState.create(game: game, player: player) }

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
end
