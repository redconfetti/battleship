class PlayerGameState < ActiveRecord::Base
  belongs_to :game
  belongs_to :player

  validate :limit_two_per_game

  serialize :battle_grid, Array
  serialize :tracking_grid, Array

  before_create :initialize_state
  before_create :build_battle_grid

  # Grid States
  WATER = 'w'
  SHIP = 's'
  HIT = 'h'
  MISS = 'm'

  # Grid Movements
  SOUTH = 'S'
  EAST = 'E'

  FLEET = [5,4,3,2,2,1,1]

  def self.for_game(game_id)
    where(game_id: game_id)
  end

  # Limits to two players associated with game
  def limit_two_per_game
    if new_record? && self.class.for_game(self.game_id).count > 1
      errors.add(:game, "Cannot add more than 2 players to a Game")
    end
  end

  def as_json(options = {})
    options[:include] = [:game, :player]
    super(options).merge({
      'battleGridStats' => {
        'hits' => hits.count,
        'misses' => misses.count,
        'remaining' => remaining.count,
      },
      'pusherKey' => Pusher.key
    })      
  end

  def enemy_player_state
    game.player_game_states.where.not(id: id).first
  end

  ###########################
  # Battle Actions
  def receive_shot(x, y)
    battle_grid[x][y] = MISS if battle_grid[x][y] == WATER
    battle_grid[x][y] = HIT if battle_grid[x][y] == SHIP
    update_enemy_tracking(x, y, battle_grid[x][y])
    save
  end

  def update_enemy_tracking(x, y, value)
    enemy = enemy_player_state
    enemy.tracking_grid[x][y] = value
    enemy.save
  end

  def hits
    grid_collect('battle') {|grid, x, y| [x,y] if grid[x][y] == PlayerGameState::HIT}
  end

  def misses
    grid_collect('battle') {|grid, x, y| [x,y] if grid[x][y] == PlayerGameState::MISS}
  end

  def remaining
    grid_collect('battle') {|grid, x, y| [x,y] if grid[x][y] == PlayerGameState::SHIP}
  end

  def defeated?
    remaining.count > 0
  end

  ###########################
  # Grid Generation

  def initialize_state
    grid = []
    (0..9).to_a.each do |x|
      grid[x] = []
      (0..9).to_a.each do |y|
        grid[x][y] = WATER
      end
    end
    self.tracking_grid = grid.dup
    self.battle_grid = grid.dup
  end

  def build_battle_grid
    PlayerGameState::FLEET.shuffle.each do |ship_length|
      space = available_placements(ship_length).sample
      place_ship(space[0], space[1], ship_length, space[2])
    end
  end

  # Returns available placements for battlegrid
  def available_placements(length)
    available_placements = []
    positions = {}

    grid_map!('battle') do |grid, x, y|
      [SOUTH, EAST].each do |direction|
        if valid_placement?(x, y, length, direction)
          available_placements << [x, y, direction]
        end
      end
    end
    available_placements
  end

  # Places ship on battle grid
  def place_ship(x, y, length, direction)
    raise ArgumentError, "Invalid placement for #{length} space ship at [#{x},#{y}] positioned #{direction}" unless valid_placement?(x, y, length, direction)
    ship_coordinates = get_coordinates(x, y, length, direction)
    ship_coordinates.each do |space|
      battle_grid[space[0]][space[1]] = SHIP
    end
  end

  # Returns true if placement on grid and available
  def valid_placement?(x, y, length, direction)
    coordinates = get_coordinates(x, y, length, direction)
    return false if !coordinates
    coordinates.each do |coordinate|
      return false if battle_grid[coordinate[0]][coordinate[1]] != WATER
    end
    true
  end

  # Provides coordinates for ship placement on battlefield
  # Returns false if falls outside of grid
  def get_coordinates(start_x, start_y, length, direction)
    coordinates = []
    current_x = start_x
    current_y = start_y

    length.times do
      return false if is_outside_of_grid?(current_x, current_y)
      coordinates << [current_x, current_y]
      next_position = neighbor_position(current_x, current_y, direction)
      current_x = next_position[0]
      current_y = next_position[1]
    end
    coordinates
  end

  # Returns coordinates for position East or South of provided position
  def neighbor_position(x, y, direction)
    raise ArgumentError, "Direction '#{direction}' is invalid. Must be '#{SOUTH}' or '#{EAST}'" if [EAST, SOUTH].index(direction) == nil
    return [x + 1, y] if direction == EAST
    return [x, y + 1] if direction == SOUTH
  end

  # Returns false if coordinate outside of grid
  def is_outside_of_grid?(x, y)
    return true if (x < 0 || x > 9)
    return true if (y < 0 || y > 9)
    false
  end

  # Used to iterate and modify all grid positions
  def grid_map!(grid_type, &block)
    (0..9).to_a.each do |x|
      (0..9).to_a.each do |y|
        yield(battle_grid, x,y) if grid_type == 'battle'
        yield(tracking_grid, x,y) if grid_type == 'tracking'
      end
    end
  end

  # Used to collect matching grid sets
  def grid_collect(grid_type, &block)
    collection = []
    (0..9).to_a.each do |x|
      (0..9).to_a.each do |y|
        result = yield(battle_grid, x,y) if grid_type == 'battle'
        result = yield(tracking_grid, x,y) if grid_type == 'tracking'
        collection << result if result
      end
    end
    collection
  end

  # Displays battle grid in console for human verification (and warm fuzzies)
  def print_grid
    print "\n"
    (0..9).to_a.each do |x|
      print '|'
      (0..9).to_a.each do |y|
        print ' ' + battle_grid[x][y] + ' '
      end
      print "|\n"
    end
    $stdout.flush
    puts
  end

end
