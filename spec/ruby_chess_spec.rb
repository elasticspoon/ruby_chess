# frozen_string_literal: false

require 'spec_helper'
require 'rspec'
require './lib/ruby_chess'

describe BoardLocation do
  subject(:test_location) { described_class.new(2, 2) }

  describe '#parse string' do
    it 'returns array of expected values if string valid' do
      expected_values = [3, 4]
      returned_values = test_location.parse_string('d5')
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

  describe 'parse_location_input' do
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
end

describe Pawn do
  subject(:test_piece) { described_class.new(is_black) }
  let(:is_black) { true }
  describe '#valid_move' do
    before do
      allow(test_piece).to receive(:get_current_moves).and_return(returned_array)
    end
    context 'when given array of valid locations' do
      let(:returned_array) { [[1, 0]] }
      it 'returns true for [1, 1]' do
        piece_start_location = [1, 1]
        piece_end_location = [1, 0]
        expect(test_piece.valid_move?(piece_start_location, piece_end_location)).to be true
      end
      it 'returns false for [2, 1]' do
        piece_start_location = [1, 1]
        piece_end_location = [2, 1]
        expect(test_piece.valid_move?(piece_start_location, piece_end_location)).to be false
      end
    end
  end
  describe '#valid_take' do
    before do
      allow(test_piece).to receive(:get_current_moves).and_return(returned_array)
    end
    context 'when given array of valid locations' do
      let(:returned_array) { [[1, 1]] }
      it 'returns true for [1, 1]' do
        piece_start_location = [0, 0]
        piece_end_location = [1, 1]
        expect(test_piece.valid_take?(piece_start_location, piece_end_location)).to be true
      end
      it 'returns false for [2, 1]' do
        piece_start_location = [1, 1]
        piece_end_location = [2, 1]
        expect(test_piece.valid_take?(piece_start_location, piece_end_location)).to be false
      end
    end
  end

  describe '#get_current_moves' do
    let(:test_takes) { [[0, 1]] }
    let(:test_moves) { [[0, 1]] }
    before do
      allow(test_piece).to receive(:piece_moves).and_return(test_moves)
    end
    it 'returns calls piece_moves' do
      expect(test_piece).to receive(:piece_moves)
      test_piece.get_current_moves(0, 0)
    end
  end
end
