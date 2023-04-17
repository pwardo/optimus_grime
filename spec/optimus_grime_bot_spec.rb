# spec/optimus_grime_bot_spec.rb
require_relative '../optimus_grime_bot'

RSpec.describe "optimus_grime_bot", :type => :request do
  describe 'grid param validation' do
    describe "validate_grid_param_format" do
      it "should return true if grid param is in the valid format '5x5'" do
        ['5x5', '10x5', '10x100'].each do |grid_param|
          expect(validate_grid_param_format(grid_param)).to be(true)
        end
      end

      it "should return false if grid param is in an invalid format i.e. '5 5'" do
        ['5_5', '10 5', '10x', 'x10', '10y10', '-10x-10'].each do |grid_param|
          expect(validate_grid_param_format(grid_param)).to be(false)
        end
      end
    end

    describe "validate_grid_param_values" do
      it "should return true if grid param values are positive numbers i.e '5x5'" do
        [[5, 5], [10, 5], [5, 100]].each do |grid_param|
          expect(validate_grid_param_values(grid_param)).to be(true)
        end
      end

      it 'should return false if grid param values are not positive numbers' do
        [[0, 5], [5, 0], [-1, 5], [5, -15], [0, 1], [0, 1]].each do |grid_param|
          expect(validate_grid_param_values(grid_param)).to be(false)
        end
      end
    end
  end

  describe 'coordinate params validation' do
    describe 'validate_coordinate_param_format' do
      it "should return true if coordinate param is in the valid format '(1, 1)'" do
        ['(1, 4)', '(4, 1)', '(100, 100)'].each do |coordinate_param|
          expect(validate_coordinate_param_format(coordinate_param)).to be(true)
        end
      end

      it "should return false if coordinate param is in an invalid format i.e. '(1 1)'" do
        ['(1 1)', '1, 1', '(1,1)', '(1, 1', '(-1, 1)'].each do |coordinate_param|
          expect(validate_coordinate_param_format(coordinate_param)).to be(false)
        end
      end
    end

    describe "validate_coordinate_param_values" do
      let(:grid) do
        [5, 5]
      end

      it 'should return true if coordinate param values are positive values within the contraints of the grid' do
        [[1, 1], [2, 3], [5, 5]].each do |coordinate|
          expect(validate_coordinate_param_values(coordinate, grid)).to be(true)
        end
      end

      it 'should return false if coordinate param values are not positive values' do
        [[0, 1], [1, 0], [-1, 1], [1, -1]].each do |coordinate|
          expect(validate_coordinate_param_values(coordinate, grid)).to be(false)
        end
      end

      it 'should return false if coordinate param values are not within the contraints of the grid' do
        [[6, 5], [5, 6]].each do |coordinate|
          expect(validate_coordinate_param_values(coordinate, grid)).to be(false)
        end
      end
    end
  end

  describe 'get_coordinates' do
    let(:grid) do
      [5, 5]
    end

    before(:each) do
      @errors = []
    end

    it 'should return nil and create an error and if coordinates param is empty' do
      expect(get_coordinates('', grid)).to be(nil)
      expect(@errors).to include(COORDINATE_ERROR_1)
    end

    it 'should parse and return an array of coordinates if all values are valid' do
      coordinate_param = '(1, 4)', '(4, 1)', '(3, 3)'
      expect(get_coordinates(coordinate_param, grid)).to eq([[1, 4], [4, 1], [3, 3]])
      expect(@errors).to be_empty
    end

    it 'should parse and return an array of valid coordinates and create errors for coordinates outside of the grid' do
      coordinate_param = '(1, 4)', '(4, 1)', '(100, 100)'
      expect(get_coordinates(coordinate_param, grid)).to eq([[1, 4], [4, 1]])
      expect(@errors).to include("(100, 100) #{COORDINATE_ERROR_2}")
    end

    it 'should parse and return an array of valid coordinates and create errors coordinates in an invalid format' do
      coordinate_param = '(1, 4)', '(4, 1)', '100, 100'
      expect(get_coordinates(coordinate_param, grid)).to eq([[1, 4], [4, 1]])
      expect(@errors).to include("100, 100 #{COORDINATE_ERROR_3}")
    end
  end

  describe 'get_instructions' do
    it 'should generate correct instructions when given a single coordinate' do
      expect(get_instructions([[1, 1]])).to eq('ENC')
      expect(get_instructions([[2, 2]])).to eq('EENNC')
      expect(get_instructions([[1, 3]])).to eq('ENNNC')
      expect(get_instructions([[3, 1]])).to eq('EEENC')
    end

    it 'should generate correct instructions when given multiple coordinates' do
      expect(get_instructions([[1, 3], [4, 4]])).to eq('ENNNCEEENC')
      expect(get_instructions([[1, 1], [2, 2], [1, 3], [3, 1], [5, 5], [2, 2]])).to eq('ENCENCWNCEESSCEENNNNCWWWSSSC')
      expect(get_instructions([[5, 5], [4, 4], [3, 3], [3, 1], [1, 1]])).to eq('EEEEENNNNNCWSCWSCSSCWWC')
    end
  end
end
