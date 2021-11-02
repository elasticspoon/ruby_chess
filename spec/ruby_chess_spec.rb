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

describe Pawn do
  subject(:test_piece) { described_class.new(is_black) }
  let(:is_black) { true }
  describe '#valid_move' do
    before do
      allow(test_piece).to receive(:get_current_moves).and_return(returned_array)
    end
    context 'when given array of valid locations' do
      let(:returned_array) { [BoardLocation.new([1, 0])] }
      it 'returns true for [1, 1]' do
        piece_start_location = BoardLocation.new([1, 1])
        piece_end_location = BoardLocation.new([1, 0])
        expect(test_piece.valid_move?(piece_start_location, piece_end_location)).to be true
      end
      it 'returns true for [2, 1]' do
        piece_start_location = BoardLocation.new([1, 2])
        piece_end_location = BoardLocation.new([1, 0])
        expect(test_piece.valid_move?(piece_start_location, piece_end_location)).to be true
      end
      it 'returns false for [2, 1]' do
        piece_start_location = BoardLocation.new([1, 1])
        piece_end_location = BoardLocation.new([2, 1])
        expect(test_piece.valid_move?(piece_start_location, piece_end_location)).to be false
      end
    end
  end
  describe '#valid_take' do
    before do
      allow(test_piece).to receive(:get_current_takes).and_return(returned_array)
    end
    context 'when given array of valid locations' do
      let(:returned_array) { [BoardLocation.new(1, 1)] }
      it 'returns true for [1, 1]' do
        piece_start_location = BoardLocation.new([0, 0])
        piece_end_location = BoardLocation.new([1, 1])
        expect(test_piece.valid_take?(piece_start_location, piece_end_location)).to be true
      end
      it 'returns false for [2, 1]' do
        piece_start_location = BoardLocation.new([1, 1])
        piece_end_location = BoardLocation.new([2, 1])
        expect(test_piece.valid_take?(piece_start_location, piece_end_location)).to be false
      end
    end
  end

  describe '#get_current_moves' do
    let(:test_takes) { [BoardLocation.new(0, 1)] }
    let(:test_moves) { [BoardLocation.new(0, 1)] }
    before do
      allow(test_piece).to receive(:piece_moves).and_return(test_moves)
    end
    it 'returns calls piece_moves' do
      expect(test_piece).to receive(:piece_moves)
      test_piece.get_current_moves(0, 0)
    end
  end
end

describe ChessBoard do
  subject(:test_game) { described_class.new }
  context '#check_loc' do
    it 'returns the correct piece' do
      expected_piece = Pawn.new(:white)
      returned_piece = test_game.check_loc('e2')
      expect(returned_piece).to eq expected_piece
    end
  end
end
