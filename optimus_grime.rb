#!/usr/bin/ruby
require_relative 'optimus_grime_bot'
require_relative 'constants'
# require 'debug'

grid_param, *coordinates_params = ARGV
optimus_grime = OptimusGrimeBot.new(grid_param, coordinates_params)

while !optimus_grime.grid_is_valid?
  puts "Please enter a valid grid param i.e. '5x5'"
  optimus_grime.grid_param = STDIN.gets.chomp
end

optimus_grime.process_coordinates
while !optimus_grime.invalid_coordinates.empty?
  puts "You have #{optimus_grime.invalid_coordinates.length} invalid coordinates, would you like to fix them? [Y/n]"

  if STDIN.gets.chomp.downcase == 'y'
    optimus_grime.invalid_coordinates.each do |invalid_coordinate|
      value = invalid_coordinate[:value]
      while !optimus_grime.coordinate_is_valid?(value)
        puts "#{invalid_coordinate[:error_message]}. Please enter new value for '#{invalid_coordinate[:value]}'"
        value = STDIN.gets.chomp
      end

      if optimus_grime.coordinate_is_valid?(value)        
        optimus_grime.valid_coordinates[invalid_coordinate[:idx]] = optimus_grime.parse_coordinate(value)
        optimus_grime.invalid_coordinates.delete(invalid_coordinate)
      end
    end
  else
    puts "Goodbye!!"
    return
  end

end

puts optimus_grime.get_instructions

