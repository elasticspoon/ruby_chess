# frozen_string_literal: false

require 'spec_helper'
require 'rspec'
require './lib/ruby_chess'

describe BoardLocation do
  subject(:test_location) { described_class.new(2, 2) }

  describe '#parse string' do
    it 'returns [7, 4] if e8' do
      expected_values = [7, 4]
      returned_values = test_location.parse_string('e8')
      expect(returned_values).to eql expected_values
    end

    it 'returns [1, 3] if d2' do
      expected_values = [1, 3]
      returned_values = test_location.parse_string('d2')
      expect(returned_values).to eql expected_values
    end

    it 'returns false if piece location was not inbounds (letter)' do
      expected_values = false
      returned_values = test_location.parse_string('i5')
      expect(returned_values).to eql expected_values
    end

    it 'returns false if piece location was not inbounds (number)' do
      expected_values = false
      returned_values = test_location.parse_string('g9')
      expect(returned_values).to eql expected_values
    end

    context 'when edge cases' do
      it 'returns [0, 0] if "a1"' do
        expected_values = [0, 0]
        returned_values = test_location.parse_string('a1')
        expect(returned_values).to eql expected_values
      end
      it 'returns [7, 7] if "h8"' do
        expected_values = [7, 7]
        returned_values = test_location.parse_string('h8')
        expect(returned_values).to eql expected_values
      end
    end
  end

  describe '#parse_location_input' do
    context 'when given a string input' do
      it 'calls parse string when given an array containing only a string' do
        expected_values = [7, 7]
        returned_values = test_location.parse_location_input(['h8'])
        expect(returned_values).to eql expected_values
      end

      it 'returns false if parse_string false' do
        allow(test_location).to receive(:parse_string).and_return(false)
        returned_values = test_location.parse_location_input(['j9'])
        expect(returned_values).to be false
      end
    end

    context 'when given 2 inputs' do
      it 'returns array of both if both valid ints' do
        expected_values = [7, 7]
        returned_values = test_location.parse_location_input([7, 7])
        expect(returned_values).to eql expected_values
      end
    end
  end

  describe '#+' do
    context 'when combining BoardLocations' do
      let(:other_loc) { described_class.new(4, 5) }
      it 'returns a BoardLocation with x = 6, y = 7' do
        expected_loc = described_class.new(6, 7)
        returned_loc = test_location + other_loc
        expect(returned_loc).to eq expected_loc
      end
    end
  end

  describe '#*' do
    context 'when mult Int to board location' do
      it 'returns BoardLocation with int added to both x and y' do
        expected_loc = described_class.new(8, 8)
        expect(test_location * 4).to eq expected_loc
      end
    end
  end

  describe '#==' do
    it 'returns false if other is not a board location' do
      loc_one = BoardLocation.new('a1')
      loc_two = 'j'
      expect(loc_one == loc_two).to be false
    end

    it 'returns true if boardlocations have same x and y' do
      loc_one = BoardLocation.new(2, 2)
      loc_two = BoardLocation.new(2, 2)
      expect(loc_one == loc_two).to be true
    end

    it 'returns false if boardlocations have diff x and y' do
      loc_one = BoardLocation.new(2, 2)
      loc_two = BoardLocation.new(2, 3)
      expect(loc_one == loc_two).to be false
    end
  end

  describe '#initialize' do
    context 'when given a BoardLocation' do
      it 'returns a board location with same values' do
        expected_loc = BoardLocation.new(4, 4)
        returned_loc = BoardLocation.new(expected_loc)
        expect(returned_loc).to eq expected_loc
      end
    end

    context 'when given a Array [2, 2]' do
      it 'returns a board location with same values' do
        expected_loc = BoardLocation.new(2, 2)
        returned_loc = BoardLocation.new([2, 2])
        expect(returned_loc).to eq expected_loc
      end
    end
  end
end
