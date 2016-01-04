require 'rails_helper'
require 'set'

RSpec.describe PlayerGameState, type: :model do
  let(:player_game_state)   { create(:player_game_state) }
  let(:game)                { player_game_state.game }
  let(:player1)             { player_game_state.player }
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

    it 'includes enemy' do
      game.add_player(player2)
      result = subject.as_json
      expect(result['enemy']).to be_an_instance_of Hash
      expect(result['enemy']['id']).to eq player2.id
    end

    it 'includes pusher key' do
      result = subject.as_json
      expect(result['pusherKey']).to eq Pusher.key
    end

    it 'includes battle grid stats' do
      subject.initialize_state
      game.add_player(player2)
      subject.place_ship(2, 4, 3, PlayerGameState::EAST)
      subject.receive_shot(7, 9) # miss
      subject.receive_shot(3, 4) # hit
      subject.receive_shot(4, 4) # hit
      subject.receive_shot(4, 8) # miss
      subject.receive_shot(3, 8) # miss
      result = subject.as_json
      expect(result['stats']).to be_an_instance_of Hash
      expect(result['stats']['hits']).to eq 2
      expect(result['stats']['misses']).to eq 3
      expect(result['stats']['remaining']).to eq 1
      expect(result['stats']['enemyHits']).to eq 0
      expect(result['stats']['enemyMisses']).to eq 0
      expect(result['stats']['enemyRemaining']).to eq 18
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

    it 'allows saving existing player in game' do
      player2_game_state = PlayerGameState.create(game: game, player: player2)
      player2_game_state.receive_shot(7, 9)
      player2_game_state.save
      expect(player2_game_state.errors.count).to eq 0
      expect(player2_game_state.battle_grid[7][9]).to_not eq PlayerGameState::WATER
    end

    it 'prevents more than two players in game' do
      game.add_player(player2)
      player3_game_state = PlayerGameState.new(game: game, player: player3)
      expect(player3_game_state.valid?).to eq false
      expect(player3_game_state.errors).to have_key(:game)
    end
  end

  describe 'before_creation' do
    describe 'initialize_state' do
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
    end

    describe 'build_battle_grid' do
      it 'automatically places ships on battlegrid' do
        battle_spaces = subject.battle_grid.flatten
        water_spaces = battle_spaces.reject { |space| space != PlayerGameState::WATER }
        expect(water_spaces.count).to eq 82
        ship_spaces = battle_spaces.reject { |space| space != PlayerGameState::SHIP }
        expect(ship_spaces.count).to eq 18      
      end
    end
  end

  describe '#enemy_player_state' do
    it 'returns nil when no other player' do
      expect(subject.enemy_player_state).to eq nil
    end

    it 'returns opponents player game state' do
      game.add_player(player2)
      result = subject.enemy_player_state
      expect(result).to be_an_instance_of PlayerGameState
      expect(result.player_id).to eq player2.id
    end
  end

  describe '#enemy_player' do
    it 'returns nil when no other player' do
      expect(subject.enemy_player).to eq nil
    end

    it 'returns opponent' do
      game.add_player(player2)
      result = subject.enemy_player
      expect(result).to be_an_instance_of Player
      expect(result.id).to eq player2.id
    end
  end

  describe 'battle actions' do
    before { subject.initialize_state }

    describe '#receive_shot' do
      before { game.add_player(player2) }
      context 'when battle grid space is water' do
        it 'marks battle grid with miss when space is water' do
          subject.receive_shot(3, 4)
          expect(subject.battle_grid[3][4]).to eq PlayerGameState::MISS
        end

        it 'updates enemy tracking with miss when space is water' do
          subject.receive_shot(3, 4)
          expect(subject.enemy_player_state.tracking_grid[3][4]).to eq PlayerGameState::MISS
        end
      end

      context 'when battle grid space is ship' do
        before { subject.place_ship(2, 4, 5, PlayerGameState::EAST) }
        it 'marks battle grid with hit' do
          subject.receive_shot(3, 4)
          expect(subject.battle_grid[3][4]).to eq PlayerGameState::HIT
        end

        it 'updates enemy tracking with hit' do
          subject.receive_shot(3, 4)
          expect(subject.enemy_player_state.tracking_grid[3][4]).to eq PlayerGameState::HIT
        end
      end

      it 'saves updates' do
        subject.receive_shot(3, 4)
        expect(subject.reload.battle_grid[3][4]).to eq PlayerGameState::MISS
      end
    end

    describe '#update_enemy_tracking' do
      it 'applies value to enemy tracking grid' do
        game.add_player(player2)
        subject.update_enemy_tracking(4, 8, PlayerGameState::MISS)
        enemy_game_state = game.player_state(player2)
        expect(enemy_game_state).to be_an_instance_of PlayerGameState
        expect(enemy_game_state.tracking_grid[4][8]).to eq PlayerGameState::MISS
      end
    end

    describe '#hits' do
      it 'returns the coordinates for hit spaces' do
        game.add_player(player2)
        subject.place_ship(2, 4, 5, PlayerGameState::EAST)
        subject.receive_shot(7, 9) # miss
        subject.receive_shot(3, 4) # hit
        subject.receive_shot(4, 4) # hit
        subject.receive_shot(4, 8) # miss
        subject.receive_shot(3, 8) # miss
        expect(subject.hits).to eq [[3,4],[4,4]]
      end
    end

    describe '#misses' do
      it 'returns the number of opponent misses' do
        game.add_player(player2)
        subject.place_ship(2, 4, 5, PlayerGameState::EAST)
        subject.receive_shot(7, 9) # miss
        subject.receive_shot(3, 4) # hit
        subject.receive_shot(4, 8) # miss
        subject.receive_shot(3, 8) # miss
        expect(subject.misses).to eq [[3,8],[4,8],[7,9]]
      end
    end

    describe '#remaining' do
      it 'returns the number of remaining ship placements' do
        game.add_player(player2)
        subject.place_ship(2, 4, 2, PlayerGameState::EAST)
        subject.receive_shot(3, 4) # hit
        expect(subject.remaining).to eq [[2,4]]
      end
    end

    describe '#enemy_hit_count' do
      it 'returns 0 if no enemy present' do
        expect(subject.enemy_hit_count).to eq 0
      end

      it 'returns the number of enemy spaces hit' do
        game.add_player(player2)
        player1_game_state = game.player_state(player1)
        player2_game_state = game.player_state(player2)
        player1_game_state.initialize_state
        player2_game_state.initialize_state
        player2_game_state.place_ship(2, 4, 5, PlayerGameState::EAST)
        player2_game_state.receive_shot(3, 4) # hit
        player2_game_state.receive_shot(5, 4) # hit
        player2_game_state.receive_shot(3, 5) # miss
        expect(player1_game_state.enemy_hit_count).to eq 2
      end
    end

    describe '#enemy_misses_count' do
      it 'returns 0 if no enemy present' do
        expect(subject.enemy_misses_count).to eq 0
      end

      it 'returns the number of enemy spaces hit' do
        game.add_player(player2)
        player1_game_state = game.player_state(player1)
        player2_game_state = game.player_state(player2)
        player1_game_state.initialize_state
        player2_game_state.initialize_state
        player2_game_state.place_ship(2, 4, 5, PlayerGameState::EAST)
        player2_game_state.receive_shot(3, 4) # hit
        player2_game_state.receive_shot(5, 4) # hit
        player2_game_state.receive_shot(3, 5) # miss
        expect(player1_game_state.enemy_misses_count).to eq 1
      end
    end

    describe '#enemy_remaining_count' do
      it 'returns 0 if no enemy present' do
        expect(subject.enemy_remaining_count).to eq 0
      end

      it 'returns the number of enemy spaces remaining' do
        game.add_player(player2)
        player1_game_state = game.player_state(player1)
        player2_game_state = game.player_state(player2)
        player1_game_state.initialize_state
        player2_game_state.initialize_state
        player2_game_state.place_ship(2, 4, 5, PlayerGameState::EAST)
        player2_game_state.receive_shot(3, 4) # hit
        player2_game_state.receive_shot(5, 4) # hit
        player2_game_state.receive_shot(3, 5) # miss
        expect(player1_game_state.enemy_remaining_count).to eq 3
      end
    end

    describe '#defeated?' do
      it 'returns false when ship placements still remaining' do
        game.add_player(player2)
        subject.place_ship(2, 4, 2, PlayerGameState::SOUTH)
        subject.receive_shot(2, 4) # hit
        subject.receive_shot(2, 6) # miss
        expect(subject.defeated?).to eq false
      end

      it 'returns true when ship placements all hit' do
        game.add_player(player2)
        subject.place_ship(2, 4, 2, PlayerGameState::SOUTH)
        subject.receive_shot(2, 4) # hit
        subject.receive_shot(2, 5) # hit
        expect(subject.defeated?).to eq true
      end
    end
  end

  describe 'grid generation' do
    before { subject.initialize_state }

    describe '#available_placements' do
      context 'when spaces taken' do
        before { subject.place_ship(5, 4, 5, PlayerGameState::SOUTH) }
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
            expect([PlayerGameState::SOUTH, PlayerGameState::EAST].index(placement[2])).to_not be_nil
          end
        end
      end

      context 'when all spaces taken' do
        before do
          subject.grid_map!('battle') { |grid, x, y| grid[x][y] = PlayerGameState::SHIP }
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
        expect { subject.place_ship(8, 2, 3, PlayerGameState::EAST) }.to raise_error(ArgumentError, "Invalid placement for 3 space ship at [8,2] positioned E")
      end

      it 'places ship in correct coordinates horizontally' do
        subject.place_ship(3, 5, 3, PlayerGameState::EAST)
        expect(subject.battle_grid[3][5]).to eq PlayerGameState::SHIP # first space should be ship
        expect(subject.battle_grid[4][5]).to eq PlayerGameState::SHIP # second space should be ship
        expect(subject.battle_grid[5][5]).to eq PlayerGameState::SHIP # third space should be ship
        expect(subject.battle_grid[2][5]).to eq PlayerGameState::WATER # west of first space should be water
        expect(subject.battle_grid[3][4]).to eq PlayerGameState::WATER # north of first space should be water
        expect(subject.battle_grid[3][6]).to eq PlayerGameState::WATER # south of first space should be water
        expect(subject.battle_grid[6][5]).to eq PlayerGameState::WATER # east of last space should be water
      end

      it 'places ship in correct coordinates vertically' do
        subject.place_ship(3, 5, 3, PlayerGameState::SOUTH)
        expect(subject.battle_grid[3][5]).to eq PlayerGameState::SHIP # first space should be ship
        expect(subject.battle_grid[3][6]).to eq PlayerGameState::SHIP # second space should be ship
        expect(subject.battle_grid[3][7]).to eq PlayerGameState::SHIP # third space should be ship
        expect(subject.battle_grid[2][5]).to eq PlayerGameState::WATER # west of first space should be water
        expect(subject.battle_grid[3][4]).to eq PlayerGameState::WATER # north of first space should be water
        expect(subject.battle_grid[4][5]).to eq PlayerGameState::WATER # east of first space should be water
        expect(subject.battle_grid[3][8]).to eq PlayerGameState::WATER # south of last space should be water
      end
    end

    describe '#valid_placement?' do
      it 'returns true when placement falls in of grid' do
        expect(subject.valid_placement?(7, 2, 3, PlayerGameState::EAST)).to eq true
        expect(subject.valid_placement?(2, 7, 3, PlayerGameState::SOUTH)).to eq true
      end

      it 'returns false when placement falls outside of grid' do
        expect(subject.valid_placement?(8, 2, 3, PlayerGameState::EAST)).to eq false
        expect(subject.valid_placement?(2, 8, 3, PlayerGameState::SOUTH)).to eq false
      end
    end

    describe '#get_coordinates' do
      it 'raises exception when invalid direction argument received' do
        expect { subject.get_coordinates(4, 4, 3, 'N') }.to raise_error(ArgumentError, "Direction 'N' is invalid. Must be 'S' or 'E'")
        expect { subject.get_coordinates(4, 4, 3, 'W') }.to raise_error(ArgumentError, "Direction 'W' is invalid. Must be 'S' or 'E'")
      end

      it 'returns coordinates' do
        result = subject.get_coordinates(0, 0, 3, PlayerGameState::SOUTH)
        expect(result).to be_an_instance_of Array
        expect(result.count).to eq 3
        expect(result).to eq [[0, 0], [0, 1], [0, 2]]

        result = subject.get_coordinates(5, 7, 2, PlayerGameState::EAST)
        expect(result).to be_an_instance_of Array
        expect(result.count).to eq 2
        expect(result).to eq [[5, 7], [6, 7]]
      end

      it 'returns false if coordinate falls outside of grid' do
        expect(subject.get_coordinates(4, 9, 2, PlayerGameState::SOUTH)).to eq false
        expect(subject.get_coordinates(9, 0, 2, PlayerGameState::EAST)).to eq false
        expect(subject.get_coordinates(9, 9, 2, PlayerGameState::SOUTH)).to eq false
        expect(subject.get_coordinates(9, 9, 2, PlayerGameState::EAST)).to eq false
        expect(subject.get_coordinates(9, 8, 3, PlayerGameState::EAST)).to eq false
        expect(subject.get_coordinates(6, 7, 4, PlayerGameState::SOUTH)).to eq false
        expect(subject.get_coordinates(7, 8, 4, PlayerGameState::EAST)).to eq false
      end
    end

    describe '#neighbor_position' do
      it 'raises exception when invalid direction argument received' do
        expect { subject.neighbor_position(4, 4, 'N') }.to raise_error(ArgumentError, "Direction 'N' is invalid. Must be 'S' or 'E'")
        expect { subject.neighbor_position(4, 4, 'W') }.to raise_error(ArgumentError, "Direction 'W' is invalid. Must be 'S' or 'E'")
      end

      it 'returns position south' do
        expect(subject.neighbor_position(4, 4, PlayerGameState::SOUTH)).to eq [4,5]
      end

      it 'returns position east' do
        expect(subject.neighbor_position(4, 4, PlayerGameState::EAST)).to eq [5,4]
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
        subject.place_ship(2, 3, 2, PlayerGameState::EAST)
        result = subject.grid_collect('battle') { |grid, x, y| [x,y] if grid[x][y] != PlayerGameState::WATER } # get all non-water
        expect(result).to be_an_instance_of Array
        expect(result.count).to eq 2
        expect(result[0]).to eq [2,3]
        expect(result[1]).to eq [3,3]
      end
    end

    describe '#grid_map!' do
      it 'allows custom operation on each grid space' do
        subject.grid_map!('battle') { |grid, x, y| grid[x][y] = PlayerGameState::SHIP } # set all spaces to 's'
        battle_spaces = subject.battle_grid.flatten
        water_spaces = battle_spaces.reject { |space| space != PlayerGameState::WATER }
        expect(water_spaces.count).to eq 0
      end
    end

  end

end
