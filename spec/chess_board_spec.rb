# frozen_string_literal: false

require 'spec_helper'
require 'rspec'
require './lib/ruby_chess'

describe ChessBoard do
  subject(:test_board) { described_class.new }

  context '#starting_board' do
    it 'generates a starting board with row 1 being white pawns' do
      generated_board = test_board.board
      num_black_pawns = generated_board[1].filter(&:black?).length
      expect(generated_board[1]).to all(be_a_instance_of(Pawn))
      expect(num_black_pawns).to eq(0)
    end
    it 'generates a starting board with row 6 being black pawns' do
      generated_board = test_board.board
      num_black_pawns = generated_board[6].filter(&:black?).length
      expect(generated_board[6]).to all(be_a_instance_of(Pawn))
      expect(num_black_pawns).to eq(8)
    end
    it 'generates a starting board with rows 2-5 being empty' do
      generated_board = test_board.board
      (2..5).each do |row_num|
        expect(generated_board[row_num]).to all(be_nil)
      end
    end
    let(:expected_edge_rows) { [Rook, Knight, Bishop, Queen, King] + [Rook, Knight, Bishop].reverse }
    it 'generates correct bottom row' do
      generated_bot_row = test_board.board[0].map { |piece| piece.class }
      num_black_pieces = test_board.board[0].filter(&:black?).length
      expect(generated_bot_row).to eq(expected_edge_rows)
      expect(num_black_pieces).to be_zero
    end
    it 'generates correct top row' do
      generated_bot_row = test_board.board[7].map { |piece| piece.class }
      num_black_pieces = test_board.board[7].filter(&:black?).length
      expect(generated_bot_row).to eq(expected_edge_rows)
      expect(num_black_pieces).to eq(8)
    end
  end

  context '#check_loc' do
    it 'returns the correct piece' do
      expected_piece = Pawn.new(:white)
      returned_piece = test_board.check_loc('e2')
      expect(returned_piece).to eq expected_piece
    end

    it 'raises error if bad spot' do
      expect { test_board.check_loc('u2') }.to raise_error 'location err'
    end
  end
  context '#place_piece' do
    let(:some_board) { [[]] }
    it 'returns a game board with expected piece' do
      returned_board = test_board.place_piece(BoardLocation.new(0, 0), Pawn.new, some_board)
      returned_piece = returned_board[0][0]
      expect(returned_board[0]).to eq([Pawn.new])
      expect(returned_piece.loc).to eq(BoardLocation.new(0, 0))
    end
  end

  context '#remove_piece' do
    let(:some_board) { [[Pawn.new]] }
    it 'returns a game board without expected piece' do
      returned_board = test_board.remove_piece(BoardLocation.new(0, 0), some_board)
      expect(returned_board.flatten).to eq([nil])
    end
  end

  context '#piece_move' do
    let(:tiny_board) { [[Pawn.new, Pawn.new, nil]] }
    let(:start_loc) { BoardLocation.new(0, 0) }
    let(:end_loc) { BoardLocation.new(0, 1) }
    before do
      allow(test_board).to receive(:check_loc).and_return(nil)
      allow(test_board).to receive_messages(deepCopyArr: 3, remove_piece: 2, place_piece: 3)
    end

    context 'when move called' do
      it 'calls check_loc, remove_piece, place_piece' do
        expect(test_board).to receive(:check_loc).with(start_loc, tiny_board)
        expect(test_board).to receive(:remove_piece).with(start_loc, tiny_board)
        expect(test_board).to receive(:place_piece).with(end_loc, nil, tiny_board)
        test_board.piece_move(start_loc, end_loc, tiny_board)
      end
    end
  end

  context '#valid_turn?' do
    let(:turn_arr) { [[0, 0], [0, 1]] }
    let(:expected_start) { BoardLocation.new(0, 0) }
    let(:expected_end) { BoardLocation.new(0, 1) }
    it 'calls piece_take if good turn' do
      allow(test_board).to receive(:turn_attempt_bad).and_return(false)
      allow(test_board).to receive(:board).and_return(nil)
      allow(test_board).to receive(:deepCopyArr).and_return(nil)
      allow(test_board).to receive(:piece_move).and_return(4)
      expect(test_board).to receive(:piece_move).with(expected_start, expected_end, nil)
      returned_val = test_board.valid_turn?(turn_arr, false)
      expect(returned_val).to eq(4)
    end
    it 'returns false if bad turn' do
      allow(test_board).to receive(:turn_attempt_bad).and_return(true)
      returned_val = test_board.valid_turn?(turn_arr, false)
      expect(returned_val).to be false
    end
  end

  context '#turn_attempt_invalid' do
    before do
      allow(test_board).to receive(:check_loc).and_return(stubbed_piece)
      allow(test_board).to receive(:deepCopyArr).and_return(2)
    end
    let(:stubbed_piece) { instance_double(ChessPiece, nil?: is_nil, black?: is_black, valid_action?: is_valid) }
    let(:is_nil) { false }
    let(:is_black) { true }
    let(:is_valid) { true }

    context 'all inputs valid' do
      it 'returns unmodified game_board' do
        initial_game_board = 'some_board'
        returned_val = test_board.turn_attempt_invalid(nil, nil, is_black, initial_game_board)
        expect(returned_val).to equal(initial_game_board)
      end
    end
    context 'when invalid_action' do
      let(:is_valid) { false }
      it 'returns true' do
        returned_val = test_board.turn_attempt_invalid(nil, nil, is_black, nil)
        expect(returned_val).to be true
      end
    end
    context 'when piece nil' do
      let(:is_nil) { true }
      it 'returns true' do
        returned_val = test_board.turn_attempt_invalid(nil, nil, is_black, nil)
        expect(returned_val).to be true
      end
    end

    context 'when piece colors dont match' do
      let(:is_nil) { true }
      it 'returns true' do
        returned_val = test_board.turn_attempt_invalid(nil, nil, !is_black, nil)
        expect(returned_val).to be true
      end
    end
  end

  context '#turn_attempt_bad' do
  end

  context '#check?' do
    before do
      allow(test_board).to receive_messages(loc_checked?: checked_loc)
    end
    let(:piece_stub) { instance_double(ChessPiece, is_a?: type_match, black?: is_black, loc: piece_loc) }
    let(:type_match) { true }
    let(:is_black) { true }
    let(:piece_loc) { BoardLocation.new(0, 0) }
    let(:checked_loc) { false }
    let(:fake_board) { [piece_stub] }

    context 'when there is a king of same color and location is not checked' do
      it 'returns false' do
        returned_val = test_board.check?(is_black, fake_board)
        expect(returned_val).to be false
      end
    end
    context 'when location is checked' do
      let(:checked_loc) { true }
      it 'returns the stubbed piece' do
        returned_val = test_board.check?(is_black, fake_board)
        expect(returned_val).to eq(piece_stub)
      end
    end
    context 'no kings' do
      let(:type_match) { false }
      it 'returns false' do
        expect(test_board.check?(is_black, fake_board)).to be false
      end
    end
    context 'no same color' do
      it 'returns false' do
        expect(test_board.check?(!is_black, fake_board)).to be false
      end
    end
  end

  context '#loc_checked' do
    let(:piece_stub) { instance_double(ChessPiece, black?: !is_black, loc: piece_loc, is_a?: true) }
    let(:is_black) { true }
    let(:piece_loc) { BoardLocation.new(0, 0) }
    let(:invalid_turn) { true }
    let(:fake_board) { Array.new(8) { Array.new(7) + [piece_stub] } }
    before do
      allow(test_board).to receive(:deepCopyArr).and_return(nil)
      allow(test_board).to receive(:turn_attempt_invalid).and_return(invalid_turn)
    end

    context 'when pieces exist, and all invalid' do
      it 'returns false' do
        expect(test_board.loc_checked?(piece_loc, is_black, fake_board))
      end
    end
    context 'when pieces exist, and any turn valid' do
      it 'returns true' do
        allow(test_board).to receive(:turn_attempt_invalid).and_return(invalid_turn, invalid_turn, !invalid_turn)
        expect(test_board).to receive(:turn_attempt_invalid).exactly(3).times
        returned_val = test_board.loc_checked?(piece_loc, is_black, fake_board)
        expect(returned_val).to be true
      end
    end
    context 'pieces dont exist' do
      it 'returns false' do
        returned_val = test_board.loc_checked?(piece_loc, is_black, fake_board)
        expect(returned_val).to be false
      end
    end
  end

  context '#turn_attempt_bad' do
    before do
      allow(test_board).to receive(:turn_attempt_invalid).and_return(invalid_turn)
      allow(test_board).to receive(:piece_move).and_return(piece_moved)
      allow(test_board).to receive(:check?).and_return(is_checked)
      allow(test_board).to receive(:deepCopyArr).and_return(deep_arr)
    end

    let(:invalid_turn) { fake_board }
    let(:is_checked) { true }
    let(:fake_board) { [['fuck the refs']] }
    let(:piece_moved) { fake_board }
    let(:deep_arr) { 'deep_arr' }

    context 'when turn is valid and piece can be moved' do
      it 'returns if checked' do
        returned_val = test_board.turn_attempt_bad(nil, nil, nil, nil)
        expect(returned_val).to equal(is_checked)
      end

      it 'calls correct functions' do
        start_loc = 'here'
        end_loc = 'there'
        player_color = 'some color'
        expect(test_board).to receive(:piece_move).with(start_loc, end_loc, deep_arr)
        expect(test_board).to receive(:turn_attempt_invalid).with(start_loc, end_loc, player_color, fake_board)
        test_board.turn_attempt_bad(start_loc, end_loc, player_color, fake_board)
      end
    end

    context 'when turn invalid' do
      let(:invalid_turn) { true }
      it 'returns true' do
        returned_val = test_board.turn_attempt_bad(0, 0, 0, 0)
        expect(returned_val).to be true
      end
    end
  end
end
