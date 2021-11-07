# frozen_string_literal: true

class ChessBoard
  include TwoDCopy
  attr_reader :board

  def initialize
    @board = starting_board
    set_locations
  end

  def set_locations
    board.each_with_index do |row, row_num|
      row.each_with_index do |piece, col_num|
        piece&.loc = BoardLocation.new(row_num, col_num)
        piece&.update_legal_moves(board)
      end
    end
  end

  def check_loc(location, game_board = board)
    location = BoardLocation.new(location)
    piece = game_board[location.x][location.y]
    piece.loc = location unless piece.nil?
    piece
  end

  def valid_turn?(turn_array, player_color)
    move_start = BoardLocation.new(turn_array[0])
    move_end = BoardLocation.new(turn_array[1])
    return false if turn_attempt_bad(move_start, move_end, player_color, deepCopyArr(board))

    piece_move(move_start, move_end, board)
  end

  def turn_attempt_invalid(move_start, move_end, player_color, game_board)
    piece = check_loc(move_start, game_board)
    return true if piece.nil? || piece.black? != player_color
    return true unless piece.valid_action?(move_end, game_board)

    game_board
  end

  def turn_attempt_bad(move_start, move_end, player_color, game_board)
    game_board = turn_attempt_invalid(move_start, move_end, player_color, game_board)
    return true if game_board == true

    temp_board = piece_move(move_start, move_end, deepCopyArr(game_board))
    check?(player_color, temp_board)
  end

  def piece_move(move_start, move_end, game_board)
    piece = check_loc(move_start, game_board)

    remove_piece(move_start, game_board)
    place_piece(move_end, piece, game_board)
  end

  def remove_piece(location, game_board)
    game_board[location.x][location.y] = nil
    game_board
  end

  def place_piece(location, piece, game_board)
    piece.moved
    game_board[location.x][location.y] = piece
    piece.loc = location
    game_board
  end

  def starting_board
    accum = Array.new(4) { Array.new(8) { nil } }
    # accum = Array.new(6) { Array.new(8) { nil } }
    pawn_row_b = Array.new(8) { Pawn.new }
    pawn_row_w = Array.new(8) { Pawn.new(:white) }
    row_two_b = generate_bot_row
    row_two_w = generate_bot_row(:white)
    accum.prepend(pawn_row_w).prepend(row_two_w).append(pawn_row_b).append(row_two_b)
    # accum.prepend(row_two_w).append(row_two_b)
  end

  def generate_bot_row(color = :black)
    start = [Rook.new(color), Knight.new(color), Bishop.new(color)]
    mid = [Queen.new(color), King.new(color)]
    start + mid + start.reverse
  end

  def piece_array_to_s(array)
    array.map { |val| val.nil? ? ' ' : val.to_s }.join(' ')
  end

  def to_s(game_board = board)
    temp = game_board.reverse.each_with_index.map { |val, i| "#{8 - i} |" + piece_array_to_s(val) }.join("\n")
    temp + "\n   _______________\n   a b c d e f g h"
  end

  def check?(player_color, game_board)
    king = game_board.flatten.find { |piece| piece.is_a?(King) && player_color == piece.black? }
    return false if king.nil?

    loc_checked?(king.loc, player_color, game_board) ? king : false
  end

  def loc_checked?(location, player_color, game_board)
    pieces = game_board.flatten.compact.filter { |piece| piece.is_a?(ChessPiece) && piece.black? != player_color }
    return false if pieces.empty?

    pieces.each do |other_piece|
      return true unless turn_attempt_invalid(other_piece.loc, location, other_piece.black?, game_board) == true
    end
    false
  end
end
