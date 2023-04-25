require_relative '../constants'
require_relative '../optimus_grime_bot'

RSpec.describe "OptimusGrimeBot", :type => :request do
  describe 'grid param validation' do
    describe 'grid_format_is_valid?' do
      it "should return true if grid param is in the valid format '5x5'" do
        ['5x5', '10x5', '10x100'].each do |grid_param|
          optimus_grime = OptimusGrimeBot.new(grid_param, '')
          expect(optimus_grime.send(:grid_format_is_valid?)).to be(true)
        end
      end

      it "should return false if grid param is in an invalid format i.e. '5 5'" do
        ['5_5', '10 5', '10x', 'x10', '10y10', '-10x-10'].each do |grid_param|
          optimus_grime = OptimusGrimeBot.new(grid_param, '')
          expect(optimus_grime.send(:grid_format_is_valid?)).to be(false)
        end
      end
    end

    describe 'grid_values_are_positive?' do
      it "should return true if grid param values are positive numbers i.e '5x5'" do
        ['5x5', '10x5', '5x100'].each do |grid_param|
          optimus_grime = OptimusGrimeBot.new(grid_param, '')
          expect(optimus_grime.send(:grid_values_are_positive?)).to be(true)
        end
      end

      it 'should return false if grid param values are not positive numbers' do
        ['0x5', '5x0', '0x0'].each do |grid_param|
          optimus_grime = OptimusGrimeBot.new(grid_param, '')
          expect(optimus_grime.send(:grid_values_are_positive?)).to be(false)
        end
      end
    end
  end

  describe 'coordinate params validation' do
    let(:optimus_grime) do
      OptimusGrimeBot.new('5x5', '')
    end

    describe 'coordinate_format_is_valid?' do
      it "should return true if coordinate param is in the valid format '(1, 1)'" do
        ['(1, 4)', '(4, 1)', '(100, 100)'].each do |coordinate_param|
          expect(optimus_grime.send(:coordinate_format_is_valid?, coordinate_param)).to be(true)
        end
      end

      it "should return false if coordinate param is in an invalid format i.e. '(1 1)'" do
        ['(1 1)', '1, 1', '(1,1)', '(1, 1', '(-1, 1)'].each do |coordinate_param|
          expect(optimus_grime.send(:coordinate_format_is_valid?, coordinate_param)).to be(false)
        end
      end
    end

    describe 'coordinate_values_within_constraints?' do
      let(:grid) do
        [5, 5]
      end

      it 'should return true if coordinate param values are values within the contraints of the grid' do
        [[0, 1], [1, 0], [1, 1], [2, 3], [4, 4]].each do |coordinate|
          expect(optimus_grime.send(:coordinate_values_within_constraints?, coordinate, grid)).to be(true)
        end
      end

      it 'should return false if coordinate param values are less than zero' do
        [[-1, 1], [1, -1]].each do |coordinate|
          expect(optimus_grime.send(:coordinate_values_within_constraints?, coordinate, grid)).to be(false)
        end
      end

      it 'should return false if coordinate param values are not within the contraints of the grid' do
        [[5, 4], [4, 5]].each do |coordinate|
          expect(optimus_grime.send(:coordinate_values_within_constraints?, coordinate, grid)).to be(false)
        end
      end
    end
  end

  describe 'process_coordinates' do
    let(:grid_param) do
      '5x5'
    end

    it 'should populate invalid_coordinates array with one object with error' do
      optimus_grime = OptimusGrimeBot.new(grid_param, '')
      optimus_grime.process_coordinates

      expect(optimus_grime.invalid_coordinates.length).to be(1)
      expect(optimus_grime.invalid_coordinates.first[:error_message]).to eq(COORDINATE_ERROR_1)
    end

    it 'should pass coordinates to valid_coordinates array if all coordinates are valid' do
      optimus_grime = OptimusGrimeBot.new(grid_param, ['(1, 4)', '(4, 1)', '(3, 3)'])
      optimus_grime.process_coordinates
      expect(optimus_grime.valid_coordinates).to eq([[1, 4], [4, 1], [3, 3]])
      expect(optimus_grime.invalid_coordinates).to be_empty
    end

    it 'should populate the invalid_coordinates array with coordinates that are beyond grid constraints' do
      optimus_grime = OptimusGrimeBot.new(grid_param, ['(1, 4)', '(4, 1)', '(100, 100)', '(200, 200)'])
      optimus_grime.process_coordinates

      expect(optimus_grime.valid_coordinates).to eq([[1, 4], [4, 1], nil, nil])
      expect(optimus_grime.invalid_coordinates.length).to be(2)
      expect(optimus_grime.invalid_coordinates[0][:error_message]).to eq('(100, 100) ' + COORDINATE_ERROR_2)
      expect(optimus_grime.invalid_coordinates[1][:error_message]).to eq('(200, 200) ' + COORDINATE_ERROR_2)
    end

    it 'should populate the invalid_coordinates array with coordinates are in an invalid format' do
      optimus_grime = OptimusGrimeBot.new(grid_param, ['(1, 4)', '(4, 1)', '100, 100', '200, 200'])
      optimus_grime.process_coordinates

      expect(optimus_grime.valid_coordinates).to eq([[1, 4], [4, 1], nil, nil])
      expect(optimus_grime.invalid_coordinates.length).to be(2)
      expect(optimus_grime.invalid_coordinates[0][:error_message]).to eq('100, 100 ' + COORDINATE_ERROR_3)
      expect(optimus_grime.invalid_coordinates[1][:error_message]).to eq('200, 200 ' + COORDINATE_ERROR_3)
    end
  end

  describe 'get_instructions' do
    let(:grid_param) do
      '5x5'
    end

    it 'should generate correct instructions when given a single coordinate' do
      optimus_grime = OptimusGrimeBot.new(grid_param, ['(1, 1)'])
      optimus_grime.process_coordinates
      expect(optimus_grime.get_instructions).to eq('ENC')

      optimus_grime = OptimusGrimeBot.new(grid_param, ['(2, 2)'])
      optimus_grime.process_coordinates
      expect(optimus_grime.get_instructions).to eq('EENNC')

      optimus_grime = OptimusGrimeBot.new(grid_param, ['(1, 3)'])
      optimus_grime.process_coordinates
      expect(optimus_grime.get_instructions).to eq('ENNNC')

      optimus_grime = OptimusGrimeBot.new(grid_param, ['(3, 1)'])
      optimus_grime.process_coordinates
      expect(optimus_grime.get_instructions).to eq('EEENC')
    end

    it 'should generate correct instructions when given multiple coordinates' do
      optimus_grime = OptimusGrimeBot.new(grid_param, ['(1, 3)', '(4, 4)'])
      optimus_grime.process_coordinates
      expect(optimus_grime.get_instructions).to eq('ENNNCEEENC')

      optimus_grime = OptimusGrimeBot.new(grid_param, ['(1, 1)', '(2, 2)', '(1, 3)', '(3, 1)', '(4, 4)', '(2, 2)'])
      optimus_grime.process_coordinates
      expect(optimus_grime.get_instructions).to eq('ENCENCWNCEESSCENNNCWWSSC')

      optimus_grime = OptimusGrimeBot.new(grid_param, ['(1, 1)', '(4, 4)', '(3, 3)', '(3, 1)', '(1, 1)'])
      optimus_grime.process_coordinates
      expect(optimus_grime.get_instructions).to eq('ENCEEENNNCWSCSSCWWC')

      optimus_grime = OptimusGrimeBot.new(grid_param, ['(0, 0)', '(4, 4)', '(3, 3)', '(3, 1)', '(1, 1)', '(0, 0)'])
      optimus_grime.process_coordinates
      expect(optimus_grime.get_instructions).to eq('CEEEENNNNCWSCSSCWWCWSC')
    end
  end
end
