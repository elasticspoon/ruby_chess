# frozen_string_literal: false

require 'spec_helper'
require 'rspec'
require './lib/ruby_chess'

describe ChessPiece do
  subject(:test_piece) { described_class.new }

  context '#initialize' do
    it 'initializes without breaking' do
      expect(test_piece.piece_color).to eq(:black)
      expect(test_piece.has_moved).to be_falsey
      expect(test_piece.piece_moves).to be_falsey
      expect(test_piece.piece_type).to be_falsey
      expect(test_piece.valid_takes).to be_falsey
      expect(test_piece.valid_moves).to be_falsey
      expect(test_piece.game_state).to be_falsey
    end
  end

  context '#arrays_to_locations' do
    let(:some_array) { [[3, 4], BoardLocation.new(2, 3), []] }

    it 'returns array of boardlocations' do
      returned_array = test_piece.arrays_to_locations(some_array)
      expect(returned_array).to all(be_a(BoardLocation))
    end
  end

  context '#set_max_move_distance' do
    context 'when given an array of 4 locations' do
      let(:location_array) { Array.new(4) { BoardLocation.new(0, 1) } }
      before do
        allow(test_piece).to receive(:arrays_to_locations).and_return(location_array)
      end
      it 'returns 4 location arrays with length eq to max_move_dist = 4' do
        returned_array = test_piece.set_max_move_distance(location_array, 4)
        expect(returned_array.length).to eq(4)
        returned_array.each do |loc_array|
          expect(loc_array.length).to eq(4)
          expect(loc_array).to all(be_a(BoardLocation))
        end
      end
      it 'returns 4 location arrays with length eq to max_move_dist = 1' do
        returned_array = test_piece.set_max_move_distance(location_array, 1)
        expect(returned_array.length).to eq(4)
        returned_array.each do |loc_array|
          expect(loc_array.length).to eq(1)
          expect(loc_array[0]).to eq(BoardLocation.new(0, 1))
        end
      end
      it 'throw error if move_distance invalid' do
        expect do
          test_piece.set_max_move_distance(location_array, 0)
        end.to raise_error "can't move a distance less than 1"
      end
    end
  end

  let(:valid_location) { BoardLocation.new(4, 5) }
  let(:valid_locations) { [valid_location] }
  let(:no_valid_locations) { [] }
  context '#valid_move' do
    it 'retuns true if valid takes includes location' do
      allow(test_piece).to receive(:valid_moves).and_return(valid_locations)
      expect(test_piece.valid_move?(valid_location)).to be true
    end
    it 'retuns false if valid takes does not include location' do
      allow(test_piece).to receive(:valid_moves).and_return(no_valid_locations)
      expect(test_piece.valid_move?(valid_location)).to be false
    end
  end

  context '#update_legal_moves' do
    let(:test_board) do
      [[described_class.new, nil, nil, described_class.new, nil]]
    end

    it 'calls correct functions' do
      allow(test_piece).to receive_messages(more_piece_crap: [0, 4], state_updates: 1)
      expect(test_piece).to receive(:more_piece_crap).with(test_board)
      expect(test_piece).to receive(:state_updates).with(4, 0, test_board)
      returned_value = test_piece.update_legal_moves(test_board)
      expect(returned_value).to eq(1)
    end
  end

  context '#state_updates' do
    let(:update_state) { test_piece.state_updates(3, 4, 5) }
    it 'changes valid takes' do
      expect { update_state }.to change { test_piece.valid_takes }.from(nil).to(3)
    end
    it 'changes game_state' do
      expect { update_state }.to change { test_piece.game_state }.from(nil).to(5)
    end
    it 'changes valid moves' do
      expect { update_state }.to change { test_piece.valid_moves }.from(nil).to(4)
    end
  end

  context '#more_piece_crap' do
    let(:piece_legality) { true }
    let(:legal_moves) do
      [[BoardLocation.new(0, 1), BoardLocation.new(0, 2), BoardLocation.new(0, 3), BoardLocation.new(0, 4)]]
    end
    let(:test_board) do
      [[described_class.new, nil, nil, described_class.new, nil]]
    end

    before do
      allow(test_piece).to receive(:board_legal?).and_return(piece_legality)
      allow(test_piece).to receive(:piece_moves).and_return(legal_moves)
      allow(test_piece).to receive(:loc).and_return(start_location)
      allow(test_piece).to receive(:black?).and_return(false)
    end
    context 'when board is P _ _ p _' do
      let(:start_location) { BoardLocation.new(0, 0) }
      let(:expected_moves) { [BoardLocation.new(0, 1), BoardLocation.new(0, 2)] }
      let(:expected_takes) { [BoardLocation.new(0, 3)] }
      it 'returns valid moves: (0, 1), (0, 2) valid takes: (0, 3)' do
        expected_return = [expected_moves, expected_takes]
        actual_return = test_piece.more_piece_crap(test_board)
        expect(actual_return).to eq(expected_return)
      end
      let(:more_legal_moves) do
        Array.new(4) { legal_moves[0] }
      end
      it 'still works with larger move arrays' do
        allow(test_piece).to receive(:piece_moves).and_return(more_legal_moves)
        expected_return = [expected_moves * 4, expected_takes * 4]
        actual_return = test_piece.more_piece_crap(test_board)
        expect(actual_return).to eq(expected_return)
      end
    end
  end
  context '#valid_action?' do
    before do
      allow(test_piece).to receive_messages(
        game_state: test_board, loc: start_loc, deepCopyArr: 4,
        valid_take?: take_v, valid_move?: move_v, update_legal_moves: 4
      )
    end
    context 'when game state does not match and not valid move or take' do
      let(:take_v) { false }
      let(:move_v) { false }
      let(:start_loc) { BoardLocation.new(0, 0) }
      let(:test_board) do
        [[described_class.new, nil, nil, described_class.new, nil]]
      end
      it 'returns false' do
        expected_return = test_piece.valid_action?(nil, test_board.push(1))
        expect(expected_return).to be false
      end
      context 'when move_valid' do
        let(:move_v) { true }
        it 'returns true if valid_move' do
          expected_return = test_piece.valid_action?(nil, test_board.push(1))
          expect(expected_return).to be true
        end
      end
      context 'when take_valid' do
        let(:take_v) { true }
        it 'returns true if valid_take' do
          expected_return = test_piece.valid_action?(nil, test_board.push(1))
          expect(expected_return).to be true
        end
      end
    end
  end

  context '#is_castling' do
    before do
      allow(test_piece).to receive_messages(black?: is_black, is_a?: self_is_rook_king, loc: start_location)
    end

    let(:stubbed_piece) do
      instance_double(ChessPiece, is_a?: target_is_rook_king,
                                  black?: is_black, has_moved: move_status, nil?: is_nil)
    end
    let(:is_nil) { true }
    let(:target_is_rook_king) { true }
    let(:self_is_rook_king) { true }
    let(:is_black) { true }
    let(:move_status) { false }
    let(:fake_board) { [[test_piece, nil, nil, stubbed_piece]] }
    let(:end_location) { BoardLocation.new(0, 3) }
    let(:start_location) { BoardLocation.new(0, 0) }

    context '#is_castling' do
      context 'when some piece is not nil' do
        it 'returns false' do
          fake_board[0][2] = 5
          returned_val = test_piece.is_castling?(end_location, fake_board)
          expect(returned_val).to be false
        end
      end
      context 'when no pieces between king/rook' do
        let(:fake_board) { [[stubbed_piece, test_piece]] }
        let(:end_location) { BoardLocation.new(0, 1) }
        it 'returns empty board' do
          returned_val = test_piece.is_castling?(end_location, fake_board)
          expect(returned_val).to eq(fake_board[0])
        end
      end
      context 'when target has moved' do
        let(:move_status) { true }
        it 'returns false' do
          allow(test_piece).to receive(:has_moved).and_return(false)
          returned_val = test_piece.is_castling?(end_location, fake_board)
          expect(returned_val).to be false
        end
      end
      context 'when self has moved' do
        it 'returns false' do
          allow(test_piece).to receive(:has_moved).and_return(true)
          returned_val = test_piece.is_castling?(end_location, fake_board)
          expect(returned_val).to be false
        end
      end

      context 'when either pieces class are incorrect' do
        let(:self_is_rook_king) { false }
        it 'returns false' do
          returned_val = test_piece.is_castling?(end_location, fake_board)
          expect(returned_val).to be false
        end
      end

      context 'when all conditions met, pieces between all nil' do
        it 'returns the whole board if king and rook on ends' do
          returned_val = test_piece.is_castling?(end_location, fake_board)
          expected_val = fake_board[0]
          expect(returned_val).to eq(expected_val)
        end
        context 'when rook and king not on edges' do
          let(:start_location) { BoardLocation.new(0, 1) }
          let(:end_location) { BoardLocation.new(0, 4) }

          it 'returns part of the board if they not on ends' do
            centered_board = [5] + fake_board[0] + [nil]
            returned_val = test_piece.is_castling?(end_location, [centered_board])
            expected_val = fake_board[0]
            expect(returned_val).to eq(expected_val)
          end
        end
      end
    end
  end
end

describe Rook do
  subject(:test_piece) { described_class.new }
  context '#set_piece_moves' do
    it 'calls set_max_move_distance with correct input' do
      allow(test_piece).to receive(:set_max_move_distance)
      expected_values = [[0, 1], [0, -1], [1, 0], [-1, 0]]
      expect(test_piece).to receive(:set_max_move_distance).with(expected_values, 8)
      test_piece.set_piece_moves
    end
  end
end

describe Bishop do
  subject(:test_piece) { described_class.new }
  context '#set_piece_moves' do
    it 'calls set_max_move_distance with correct input' do
      allow(test_piece).to receive(:set_max_move_distance)
      expected_values = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
      expect(test_piece).to receive(:set_max_move_distance).with(expected_values, 8)
      test_piece.set_piece_moves
    end
  end
end

describe Queen do
  subject(:test_piece) { described_class.new }
  context '#set_piece_moves' do
    it 'calls set_max_move_distance with correct input' do
      allow(test_piece).to receive(:set_max_move_distance)
      expected_values = [[0, 1], [0, -1], [1, 0], [-1, 0], [1, 1], [1, -1], [-1, 1], [-1, -1]]
      expect(test_piece).to receive(:set_max_move_distance).with(expected_values, 8)
      test_piece.set_piece_moves
    end
  end
end

describe King do
  subject(:test_piece) { described_class.new }
  context '#set_piece_moves' do
    it 'calls set_max_move_distance with correct input' do
      allow(test_piece).to receive(:set_max_move_distance)
      expected_values = [[0, 1], [0, -1], [1, 0], [-1, 0], [1, 1], [1, -1], [-1, 1], [-1, -1]]
      expect(test_piece).to receive(:set_max_move_distance).with(expected_values, 1)
      test_piece.set_piece_moves
    end
  end
end

describe Pawn do
  subject(:test_piece) { described_class.new }
  let(:pawn_takes_arr) { [BoardLocation.new(1, 1), BoardLocation.new(1, -1)] }
  let(:pawn_moves_arr) { [BoardLocation.new(2, 0), BoardLocation.new(1, 0)] }
  let(:test_board_nil) { [nil, [nil, nil, nil], [nil, nil, nil]] }
  let(:test_board_full) { [1, [1, 1, 1], [1, 1, 1]] }
  let(:test_board) { [nil, [1, nil, 1], [nil, 1, nil]] }
  let(:start_location) { BoardLocation.new(0, 1) }
  before do
    allow(test_piece).to receive(:board_legal?).and_return(true)
    allow(test_piece).to receive(:black?).and_return(false)
    allow(test_piece).to receive(:piece_moves).and_return(pawn_moves_arr)
    allow(test_piece).to receive(:piece_takes).and_return(pawn_takes_arr)
    allow(test_piece).to receive(:loc).and_return(start_location)
  end
  context '#get_legal_takes' do
    context 'when given empty board' do
      it 'returns no legal takes' do
        expected_return = []
        actual_return = test_piece.get_legal_takes(test_board_nil)
        expect(actual_return).to eq(expected_return)
      end
    end
    context 'when given full board' do
      it 'returns 2 legal takes' do
        expected_return = [BoardLocation.new(1, 2), BoardLocation.new(1, 0)]
        actual_return = test_piece.get_legal_takes(test_board_full)
        expect(actual_return).to eq(expected_return)
      end
    end
  end
  context '#get_legal_moves' do
    context 'when given empty board' do
      it 'returns 2 legal moves if !has_moved' do
        expected_return = [BoardLocation.new(2, 1), BoardLocation.new(1, 1)]
        actual_return = test_piece.get_legal_moves(test_board_nil)
        expect(actual_return).to eq(expected_return)
      end
    end
    context 'when given full board' do
      it 'returns 0 legal moves' do
        expected_return = []
        actual_return = test_piece.get_legal_moves(test_board_full)
        expect(actual_return).to eq(expected_return)
      end
    end
    context 'when given blocked off by piece' do
      it 'returns 1 legal moves' do
        expected_return = [BoardLocation.new(1, 1)]
        actual_return = test_piece.get_legal_moves(test_board)
        expect(actual_return).to eq(expected_return)
      end
    end
  end
end

describe Knight do
  subject(:test_piece) { described_class.new }
  let(:knight_moves_arr) { [BoardLocation.new(2, 1), BoardLocation.new(1, 2)] }
  let(:test_board_nil) { [nil, [nil, nil, nil], [nil, nil, nil]] }
  let(:test_board_full) { [1, [1, 1, 1], [1, 1, 1]] }
  let(:test_board) { [nil, [nil, nil, nil], [nil, 2, nil]] }
  let(:start_location) { BoardLocation.new(0, 0) }
  before do
    allow(test_piece).to receive(:board_legal?).and_return(true)
    allow(test_piece).to receive(:piece_moves).and_return(knight_moves_arr)
    allow(test_piece).to receive(:loc).and_return(start_location)
  end
  context '#more_piece_crap' do
    it 'jumps over pieces for moves and takes' do
      expected_return = [[BoardLocation.new(1, 2)], [BoardLocation.new(2, 1)]]
      actual_return = test_piece.more_piece_crap(test_board)
      expect(actual_return).to eq(expected_return)
    end
    it 'returns no possbile takes if all nil' do
      expected_return = [[BoardLocation.new(2, 1), BoardLocation.new(1, 2)], []]
      actual_return = test_piece.more_piece_crap(test_board_nil)
      expect(actual_return).to eq(expected_return)
    end
    it 'returns no moves if all no nil' do
      expected_return = [[], [BoardLocation.new(2, 1), BoardLocation.new(1, 2)]]
      actual_return = test_piece.more_piece_crap(test_board_full)
      expect(actual_return).to eq(expected_return)
    end
  end
end
