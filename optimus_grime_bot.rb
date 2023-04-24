#!/usr/bin/ruby
# require 'debug'

GRID_ERROR = "The grid parameter must contain two postitive numbers seperated by an 'x' i.e '5x5'".freeze
COORDINATE_ERROR_1 = "You must pass in at least one coordinate".freeze
COORDINATE_ERROR_2 = "is not a valid coordinate, coordinates must contain values within the contraints of the grid".freeze
COORDINATE_ERROR_3 = "is not valid, coordinates must be in the correct format i.e. '(1, 5)'".freeze

def validate_grid_param_format(grid_param)
  grid_param.match(/^\d+x\d+$/) ? true : false
end

def validate_grid_param_values(grid)
  # grid pramater values must be positive (assumption)
  grid[0]&.positive? && grid[1]&.positive?
end

def validate_coordinate_param_format(coordinate)
  coordinate.match(/^[(]\d+[,][ ]\d+[)]$/) ? true : false
end

# coordinates must have values within the contraints of the grid
def validate_coordinate_param_values(coordinate, grid)
  (0..(grid[0] - 1)).include?(coordinate[0]) && (0..(grid[1] - 1)).include?(coordinate[1])
end

# get coordinates and populate @errors array if error are found
def get_coordinates(coordinates_params, grid)
  if coordinates_params.empty?
    @errors << COORDINATE_ERROR_1
    return
  end
  coordinates = []
  coordinates_params.each do |coordinates_param|
    if validate_coordinate_param_format(coordinates_param)
      coordinate = coordinates_param[1..-2].split(', ').map(&:to_i)
      if validate_coordinate_param_values(coordinate, grid)
        coordinates << coordinate
      else
        @errors << "#{coordinates_param} #{COORDINATE_ERROR_2}"
      end
    else
      @errors << "#{coordinates_param} #{COORDINATE_ERROR_3}"
    end
  end
  coordinates
end

def get_instructions(coordinates)
  instructions = ''

  # instructions from 0, 0 to first coordinate
  instructions += "E" * coordinates[0][0]
  instructions += "N" * coordinates[0][1]
  instructions << 'C'

  # instructions to all subsequent coordinates
  coordinates.each_cons(2) do |first, second|
    x_moves = second[0] - first[0]
    y_moves = second[1] - first[1]

    instructions += "E" * x_moves.abs if x_moves.positive?
    instructions += "W" * x_moves.abs if x_moves.negative?
    instructions += "N" * y_moves.abs if y_moves.positive?
    instructions += "S" * y_moves.abs if y_moves.negative?

    instructions << 'C'
  end
  instructions
end
