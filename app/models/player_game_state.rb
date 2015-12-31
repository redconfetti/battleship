class PlayerGameState < ActiveRecord::Base
  belongs_to :game
  belongs_to :player

  validate :limit_two_per_game

  serialize :battle_grid, Array
  serialize :tracking_grid, Array

  before_create :init_grids

  # grid states
  # w = water
  # s = ship
  # h = hit ship

  def self.for_game(game_id)
    where(game_id: game_id)
  end

  # Limits to two players associated with game
  def limit_two_per_game
    if self.class.for_game(self.game_id).count > 1
      errors.add(:game, "Cannot add more than 2 players to a Game")
    end
  end

  def init_grids
    grid = []
    (0..9).to_a.each do |x|
      grid[x] = []
      (0..9).to_a.each do |y|
        grid[x][y] = 'w'
      end
    end
    self.tracking_grid = grid.dup
    self.battle_grid = grid.dup
  end

  def build_battle_grid
    false
  end

  # Returns available placements for battlegrid
  def available_placements(length)
    available_placements = []
    positions = {}

    grid_map!('battle') do |grid, x, y|
      ['S', 'E'].each do |direction|
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
      battle_grid[space[0]][space[1]] = 's'
    end
  end

  # Returns true if placement on grid and available
  def valid_placement?(x, y, length, direction)
    coordinates = get_coordinates(x, y, length, direction)
    return false if !coordinates
    coordinates.each do |coordinate|
      return false if battle_grid[coordinate[0]][coordinate[1]] != 'w'
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
    raise ArgumentError, "Direction '#{direction}' is invalid. Must be 'S' or 'E'" if ['E','S'].index(direction) == nil
    return [x + 1, y] if direction == 'E'
    return [x, y + 1] if direction == 'S'
  end

  # Returns false if coordinate outside of grid
  def is_outside_of_grid?(x, y)
    return true if (x < 0 || x > 9)
    return true if (y < 0 || y > 9)
    false
  end

  # Used to iterate over all grid positions
  def grid_map!(grid_type, &block)
    (0..9).to_a.each do |x|
      (0..9).to_a.each do |y|
        yield(battle_grid, x,y) if grid_type == 'battle'
        yield(battle_grid, x,y) if grid_type == 'tracking'
      end
    end
  end

end
