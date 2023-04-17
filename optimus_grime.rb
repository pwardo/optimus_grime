#!/usr/bin/ruby
require_relative 'optimus_grime_bot'

# 1. get arguments
grid_param, *coordinates_params = ARGV
@errors = []

# 2. Validate grid argument format
unless validate_grid_param_format(grid_param)
  @errors << GRID_ERROR
end

# 3. Convert grid to array of ints
grid = grid_param.split('x').map(&:to_i)

# 4. Validate that grid values are positive numbers
unless validate_grid_param_values(grid)
  @errors << GRID_ERROR
end

# 5. get coordinates / @errors
coordinates = get_coordinates(coordinates_params, grid)

unless @errors.empty?
  @errors.uniq.each do |error|
    puts error
  end
  return
end

puts get_instructions(coordinates)
