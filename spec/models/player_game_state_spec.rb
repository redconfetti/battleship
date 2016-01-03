require 'rails_helper'
require 'set'

RSpec.describe PlayerGameState, type: :model do
  let(:player_game_state)   { create(:player_game_state) }
  let(:game)                { player_game_state.game }
  let(:player)              { player_game_state.player }
  let(:player2)             { create(:player2) }
  let(:player3)             { create(:player3) }
  subject                   { player_game_state }

  describe ".for_game" do
    it 'returns PlayerGameStates for game' do
      game.add_player(player2)
      result = PlayerGameState.for_game(game)
      expect(result).to be_an_instance_of PlayerGameState::ActiveRecord_Relation
      expect(result.count).to eq 2
    end
  end

  describe '#as_json' do
    it 'returns json representation' do
      expect(subject.as_json).to be_an_instance_of Hash
    end

    it 'includes game' do
      result = subject.as_json
      expect(result['game']).to be_an_instance_of Hash
      expect(result['game']['id']).to eq subject.game_id
    end

    it 'includes player' do
      result = subject.as_json
      expect(result['player']).to be_an_instance_of Hash
      expect(result['player']['id']).to eq subject.player_id
    end
  end

  describe 'associations' do
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

  describe 'validations' do
    it 'allows second player in game' do
      player2_game_state = PlayerGameState.new(game: game, player: player2)
      expect(player2_game_state.valid?).to eq true
      expect(player2_game_state.errors).to_not have_key(:game)
    end

    it 'prevents more than two players in game' do
      game.add_player(player2)
      player3_game_state = PlayerGameState.new(game: game, player: player3)
      expect(player3_game_state.valid?).to eq false
      expect(player3_game_state.errors).to have_key(:game)
    end
  end

  describe 'before_creation' do
    it 'initializes the battle and tracking grids' do
      tracking_grid = subject.tracking_grid
      battle_grid = subject.battle_grid

      [tracking_grid, battle_grid].each do |grid|
        expect(grid).to be_an_instance_of Array
        expect(grid.count).to eq 10
        grid.each do |x|
          expect(x.count).to eq 10
        end
      end
    end

    it 'automatically places ships on battlegrid' do
      battle_spaces = subject.battle_grid.flatten
      water_spaces = battle_spaces.reject { |space| space != 'w' }
      expect(water_spaces.count).to eq 82
      ship_spaces = battle_spaces.reject { |space| space != 's' }
      expect(ship_spaces.count).to eq 18      
    end
  end

  describe 'channel communication' do

    describe '#channel_name' do
      it 'returns channel name' do
        expect(subject.channel_name).to eq "game#{game.id}-player#{player.id}"
      end
    end

  end

  describe 'grid generation' do
    before { subject.init_grids }

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

    describe '#grid_collect' do
      it 'returns all elements where code block is not false' do
        subject.place_ship(2, 3, 2, 'E')
        result = subject.grid_collect('battle') { |grid, x, y| [x,y] if grid[x][y] != 'w' } # get all non-water
        expect(result).to be_an_instance_of Array
        expect(result.count).to eq 2
        expect(result[0]).to eq [2,3]
        expect(result[1]).to eq [3,3]
      end
    end

    describe '#grid_map!' do
      it 'allows custom operation on each grid space' do
        subject.grid_map!('battle') { |grid, x, y| grid[x][y] = 's' } # set all spaces to 's'
        battle_spaces = subject.battle_grid.flatten
        water_spaces = battle_spaces.reject { |space| space != 'w' }
        expect(water_spaces.count).to eq 0
      end
    end

  end

end
