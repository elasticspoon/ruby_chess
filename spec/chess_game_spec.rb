# frozen_string_literal: false

require 'spec_helper'
require 'rspec'
require './lib/ruby_chess'

describe ChessGame do
  subject(:test_game) { described_class.new }

  context '#checkmate?' do
    let(:stubbed_board) { instance_double(ChessBoard, check?: is_check, loc_checked?: is_loc_checked) }
    let(:stubbed_king) do
      instance_double(King, valid_moves: valid_moves, valid_takes: valid_takes, update_legal_moves: nil)
    end
    let(:p_color) { true }
    let(:is_loc_checked) { true }
    let(:valid_moves) { [BoardLocation.new(0, 1)] }
    let(:valid_takes) { [BoardLocation.new(0, 3)] }
    let(:fake_board) {}
  end
end
