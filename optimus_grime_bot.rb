#!/usr/bin/ruby
require_relative 'constants'
# require 'debug'

class OptimusGrimeBot
  attr_accessor :grid_param
  attr_accessor :invalid_coordinates
  attr_accessor :valid_coordinates

  def initialize(grid_param, coordinates_params)
    @grid_param = grid_param
    @coordinates_params = coordinates_params
    @invalid_coordinates = []
    @valid_coordinates = Array.new(coordinates_params.size)
  end

  def process_coordinates
    if @coordinates_params.empty?
      @invalid_coordinates << {
        idx: 0,
        value: '',
        error_message: "#{COORDINATE_ERROR_1}"
      }
      return
    end

    grid = parse_grid

    @coordinates_params.each_with_index do |coordinates_param, index|
      if coordinate_format_is_valid?(coordinates_param)
        coordinate = parse_coordinate(coordinates_param)
        if coordinate_values_within_constraints?(coordinate, grid)
          @valid_coordinates[index] = coordinate
        else
          @invalid_coordinates << {
            idx: index,
            value: coordinates_param,
            error_message: "#{coordinates_param} #{COORDINATE_ERROR_2}"
          }
        end
      else
        @invalid_coordinates << {
          idx: index,
          value: coordinates_param,
          error_message: "#{coordinates_param} #{COORDINATE_ERROR_3}"
        }
      end
    end

  end

  def get_instructions
    instructions = ''

    # instructions from 0, 0 to first coordinate
    instructions += "E" * @valid_coordinates[0][0]
    instructions += "N" * @valid_coordinates[0][1]
    instructions << 'C'

    # instructions to all subsequent coordinates
    @valid_coordinates.each_cons(2) do |first, second|
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

  def grid_is_valid?
    grid_format_is_valid? && grid_values_are_positive?
  end

  def coordinate_is_valid?(coordinate)
    coordinate_format_is_valid?(coordinate) && coordinate_values_within_constraints?(parse_coordinate(coordinate), parse_grid)
  end

  def parse_coordinate(coordinate)
    coordinate[1..-2].split(', ').map(&:to_i)
  end

  private
  def grid_format_is_valid?
    @grid_param.match(/^\d+x\d+$/) ? true : false
  end

  def grid_values_are_positive?
    grid = parse_grid
    grid[0]&.positive? && grid[1]&.positive?
  end

  def coordinate_format_is_valid?(coordinate)
    coordinate.match(/^[(]\d+[,][ ]\d+[)]$/) ? true : false
  end

  def coordinate_values_within_constraints?(coordinate, grid)
    (0..(grid[0] - 1)).include?(coordinate[0]) && (0..(grid[1] - 1)).include?(coordinate[1])
  end

  def parse_grid
    @grid_param.split('x').map(&:to_i)
  end

end