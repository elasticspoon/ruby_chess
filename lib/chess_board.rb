# frozen_string_literal: true

class ChessBoard
  include TwoDCopy
  attr_reader :board
  attr_accessor :prev_move

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
    piece&.loc = location
    piece&.update_legal_moves(game_board)
    piece
  end

  def valid_turn?(move_start, move_end, player_color)
    temp_board = turn_attempt_bad(move_start, move_end, player_color, board)
    return false if temp_board == true

    @board = temp_board
    true
  end

  def illegal_turn(piece, player_color)
    return true if piece.nil? || piece.black? != player_color

    false
  end

  def turn_attempt_invalid(move_start, move_end, player_color, game_board)
    piece = check_loc(move_start, game_board)
    return true if illegal_turn(piece, player_color)
    return true unless piece.valid_action?(move_end, game_board)

    game_board
  end

  def turn_attempt_bad(move_start, move_end, player_color, game_board)
    temp_board = nil
    if en_passant?(move_start, move_end, player_color, game_board)
      temp_board = do_en_passant(move_start, move_end, deepCopyArr(game_board))
    elsif castling?(move_start, move_end, player_color, game_board)
      temp_board = castle(move_start, move_end, deepCopyArr(game_board))
    else
      return true if turn_attempt_invalid(move_start, move_end, player_color, game_board) == true

      temp_board = piece_move(move_start, move_end, deepCopyArr(game_board))
    end
    check?(player_color, temp_board) || temp_board
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
    pawn_row_b = Array.new(8) { Pawn.new }
    pawn_row_w = Array.new(8) { Pawn.new(:white) }
    row_two_b = generate_bot_row
    row_two_w = generate_bot_row(:white)
    accum.prepend(pawn_row_w).prepend(row_two_w).append(pawn_row_b).append(row_two_b)
  end

  def en_passant?(move_start, move_end, player_color, game_board)
    piece = check_loc(move_start, game_board)
    return false if illegal_turn(piece, player_color)

    end_spot = check_loc(move_end, game_board)
    target = check_loc(BoardLocation.new(move_start.x, move_end.y), game_board)
    return false unless end_spot.nil? && piece.is_a?(Pawn) && target.is_a?(Pawn)
    return false unless (move_start.x - move_end.x).abs == 1 && (move_start.y - move_end.y).abs == 1
    return false unless prev_move[1] == target.loc && target.black? != piece.black?

    true
  end

  def do_en_passant(move_start, move_end, game_board)
    piece_move(move_start, move_end, game_board)
    remove_piece(BoardLocation.new(move_start.x, move_end.y), game_board)
  end

  def generate_bot_row(color = :black)
    start = [Rook.new(color), Knight.new(color), Bishop.new(color)]
    mid = [Queen.new(color), King.new(color)]
    tail = [Rook.new(color), Knight.new(color), Bishop.new(color)].reverse
    start + mid + tail
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

    loc_checked?(king.loc, player_color, game_board) # ? king : false
  end

  def loc_checked?(location, player_color, game_board)
    pieces = game_board.flatten.compact.filter { |piece| piece.is_a?(ChessPiece) && piece.black? != player_color }
    return false if pieces.empty?

    pieces.each do |other_piece|
      return true unless turn_attempt_invalid(other_piece.loc, location, other_piece.black?, game_board) == true
    end
    false
  end

  def pawn_promo(game_board = board)
    some_piece = game_board.flatten.compact.find do |piece|
      piece.is_a?(Pawn) && (piece.loc.x.zero? || piece.loc.x == 7)
    end
    return false unless some_piece

    temp = some_piece.promote
    game_board[some_piece.loc.x][some_piece.loc.y] = temp
    game_board
  end

  def castle(start_loc, end_loc, game_board)
    piece = check_loc(start_loc, game_board)
    piece_two = check_loc(end_loc, game_board)

    piece.is_a?(Rook) ? castling_move(piece, piece_two, game_board) : castling_move(piece_two, piece, game_board)
  end

  def castling?(start_loc, end_loc, player_color, game_board)
    piece = check_loc(start_loc, game_board)
    return false if illegal_turn(piece, player_color)
    return false unless (locs_between = piece.is_castling?(end_loc, game_board))

    locs_between.each { |loc| return false if loc_checked?(loc, player_color, game_board) }
    true
  end

  def castling_move(rook, king, game_board)
    if rook.loc.y.zero?
      piece_move(rook.loc, BoardLocation.new(rook.loc.x, king.loc.y - 1), game_board)
      piece_move(king.loc, BoardLocation.new(rook.loc.x, king.loc.y - 2), game_board)
    else
      piece_move(king.loc, BoardLocation.new(rook.loc.x, rook.loc.y - 1), game_board)
      piece_move(rook.loc, BoardLocation.new(rook.loc.x, rook.loc.y - 2), game_board)
    end
  end
end
