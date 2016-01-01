require 'rails_helper'
require 'set'

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

  describe 'before_creation' do
    it 'initializes the battle and tracking grids' do
      game_state = player1_game_state

      tracking_grid = game_state.tracking_grid
      battle_grid = game_state.battle_grid

      [tracking_grid, battle_grid].each do |grid|
        expect(grid).to be_an_instance_of Array
        expect(grid.count).to eq 10
        grid.each do |x|
          expect(x.count).to eq 10
          x.each do |y|
            expect(y).to eq 'w'
          end
        end
      end
    end
  end

  describe 'battlegrid generation' do

    describe '#build_battle_grid' do
      let(:shuffled_fleet) { [2,1,1,2,5,4,3] }
      before do
        # stub randomized result with static expectation
        fleet_stub = double(shuffle: shuffled_fleet)
        stub_const("PlayerGameState::FLEET", fleet_stub)
      end

      it 'places proper number of ship spaces on grid' do
        subject.build_battle_grid
        battle_spaces = subject.battle_grid.flatten
        water_spaces = battle_spaces.reject { |space| space != 'w' }
        expect(water_spaces.count).to eq 82
        ship_spaces = battle_spaces.reject { |space| space != 's' }
        expect(ship_spaces.count).to eq 18
      end
    end

    describe '#available_placements' do
      context 'when spaces taken' do
        before { subject.place_ship(5, 4, 5, 'S') }
        it 'returns available spaces' do
          result = subject.available_placements(2)
          placement_set = Set.new result
          expect(placement_set.include? [0, 0, "S"]).to eq true
          expect(placement_set.include? [1, 0, "S"]).to eq true
          expect(placement_set.include? [1, 0, "S"]).to eq true
          expect(placement_set.include? [1, 0, "S"]).to eq true
          expect(placement_set.include? [3, 4, "E"]).to eq true
          expect(placement_set.include? [3, 8, "E"]).to eq true
        end

        it 'does not return unavailable spaces' do
          result = subject.available_placements(2)
          placement_set = Set.new result
          expect(placement_set.include? [5, 4, "S"]).to eq false
          expect(placement_set.include? [5, 5, "S"]).to eq false
          expect(placement_set.include? [5, 6, "S"]).to eq false
          expect(placement_set.include? [5, 7, "S"]).to eq false
          expect(placement_set.include? [5, 8, "S"]).to eq false
          expect(placement_set.include? [4, 4, "E"]).to eq false
          expect(placement_set.include? [4, 8, "E"]).to eq false
        end
      end

      context 'when no spaces taken' do
        it 'returns all spaces' do
          result = subject.available_placements(3)
          expect(result).to be_an_instance_of Array
          expect(result.count).to eq 160
          result.each do |placement|
            expect(placement).to be_an_instance_of Array
            expect(placement.count).to eq 3
            expect(placement[0]).to be_an_instance_of Fixnum
            expect(placement[1]).to be_an_instance_of Fixnum
            expect(['S', 'E'].index(placement[2])).to_not be_nil
          end
        end
      end

      context 'when all spaces taken' do
        before do
          subject.grid_map!('battle') { |grid, x, y| grid[x][y] = 's' }
        end
        it 'returns no spaces' do
          result = subject.available_placements(2)
          expect(result).to be_an_instance_of Array
          expect(result.count).to eq 0
        end
      end
    end

    describe '#place_ship' do
      it 'raises exception if placement is not valid' do
        expect { subject.place_ship(8, 2, 3, 'E') }.to raise_error(ArgumentError, "Invalid placement for 3 space ship at [8,2] positioned E")
      end

      it 'places ship in correct coordinates horizontally' do
        subject.place_ship(3, 5, 3, 'E')
        expect(subject.battle_grid[3][5]).to eq 's' # first space should be ship
        expect(subject.battle_grid[4][5]).to eq 's' # second space should be ship
        expect(subject.battle_grid[5][5]).to eq 's' # third space should be ship
        expect(subject.battle_grid[2][5]).to eq 'w' # west of first space should be water
        expect(subject.battle_grid[3][4]).to eq 'w' # north of first space should be water
        expect(subject.battle_grid[3][6]).to eq 'w' # south of first space should be water
        expect(subject.battle_grid[6][5]).to eq 'w' # east of last space should be water
      end

      it 'places ship in correct coordinates vertically' do
        subject.place_ship(3, 5, 3, 'S')
        expect(subject.battle_grid[3][5]).to eq 's' # first space should be ship
        expect(subject.battle_grid[3][6]).to eq 's' # second space should be ship
        expect(subject.battle_grid[3][7]).to eq 's' # third space should be ship
        expect(subject.battle_grid[2][5]).to eq 'w' # west of first space should be water
        expect(subject.battle_grid[3][4]).to eq 'w' # north of first space should be water
        expect(subject.battle_grid[4][5]).to eq 'w' # east of first space should be water
        expect(subject.battle_grid[3][8]).to eq 'w' # south of last space should be water
      end
    end

    describe '#valid_placement?' do
      it 'returns true when placement falls in of grid' do
        expect(subject.valid_placement?(7, 2, 3, 'E')).to eq true
        expect(subject.valid_placement?(2, 7, 3, 'S')).to eq true
      end

      it 'returns false when placement falls outside of grid' do
        expect(subject.valid_placement?(8, 2, 3, 'E')).to eq false
        expect(subject.valid_placement?(2, 8, 3, 'S')).to eq false
      end
    end

    describe '#get_coordinates' do
      it 'raises exception when invalid direction argument received' do
        expect { subject.get_coordinates(4, 4, 3, 'N') }.to raise_error(ArgumentError, "Direction 'N' is invalid. Must be 'S' or 'E'")
        expect { subject.get_coordinates(4, 4, 3, 'W') }.to raise_error(ArgumentError, "Direction 'W' is invalid. Must be 'S' or 'E'")
      end

      it 'returns coordinates' do
        result = subject.get_coordinates(0, 0, 3, 'S')
        expect(result).to be_an_instance_of Array
        expect(result.count).to eq 3
        expect(result).to eq [[0, 0], [0, 1], [0, 2]]

        result = subject.get_coordinates(5, 7, 2, 'E')
        expect(result).to be_an_instance_of Array
        expect(result.count).to eq 2
        expect(result).to eq [[5, 7], [6, 7]]
      end

      it 'returns false if coordinate falls outside of grid' do
        expect(subject.get_coordinates(4, 9, 2, 'S')).to eq false
        expect(subject.get_coordinates(9, 0, 2, 'E')).to eq false
        expect(subject.get_coordinates(9, 9, 2, 'S')).to eq false
        expect(subject.get_coordinates(9, 9, 2, 'E')).to eq false
        expect(subject.get_coordinates(9, 8, 3, 'E')).to eq false
        expect(subject.get_coordinates(6, 7, 4, 'S')).to eq false
        expect(subject.get_coordinates(7, 8, 4, 'E')).to eq false
      end
    end

    describe '#neighbor_position' do
      it 'raises exception when invalid direction argument received' do
        expect { subject.neighbor_position(4, 4, 'N') }.to raise_error(ArgumentError, "Direction 'N' is invalid. Must be 'S' or 'E'")
        expect { subject.neighbor_position(4, 4, 'W') }.to raise_error(ArgumentError, "Direction 'W' is invalid. Must be 'S' or 'E'")
      end

      it 'returns position south' do
        expect(subject.neighbor_position(4, 4, 'S')).to eq [4,5]
      end

      it 'returns position east' do
        expect(subject.neighbor_position(4, 4, 'E')).to eq [5,4]
      end
    end

    describe '#is_outside_of_grid?' do
      it 'returns false when x and y in range' do
        expect(subject.is_outside_of_grid?(1, 2)).to eq false
        expect(subject.is_outside_of_grid?(0, 9)).to eq false
        expect(subject.is_outside_of_grid?(9, 0)).to eq false
        expect(subject.is_outside_of_grid?(4, 9)).to eq false
      end

      it 'returns true when x or y are out of range' do
        expect(subject.is_outside_of_grid?(1, -1)).to eq true
        expect(subject.is_outside_of_grid?(-2, 0)).to eq true
        expect(subject.is_outside_of_grid?(10, 4)).to eq true
        expect(subject.is_outside_of_grid?(4, 10)).to eq true
        expect(subject.is_outside_of_grid?(11, -1)).to eq true
      end
    end

  end

end
