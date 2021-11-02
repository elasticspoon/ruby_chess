# frozen_string_literal: true

require_relative 'piece_movement'
require_relative 'board_location'
require_relative 'chess_pieces'

class ChessGame
  attr_reader :chess_board

  def initialize
    @chess_board = ChessBoard.new
    @white_turn = true
  end

  def white_turn
    @white_turn = !@white_turn
    !@white_turn
  end

  def parse_input(player_input)
    matcher = player_input.downcase.match(/^([a-h][1-8])\s*([a-h][1-8])$/)
    return false if matcher.nil?

    [BoardLocation.new(matcher[1]), BoardLocation.new(matcher[2])]
  end

  def turn_loop
    loop do
      puts 'Input a move in a1 b2 format.'
      input = parse_input(gets.chomp)
      next unless input
      break if chess_board.turn_attempt(input)
    end
  end

  def game_loop
    puts 'Play Chess:'
    loop do
      puts chess_board
      puts "#{@white_turn ? 'White' : 'Black'} turn:"
      turn_loop
      white_turn
    end
  end
end

class ChessBoard
  attr_reader :board

  def initialize
    @board = starting_board
  end

  def check_loc(location)
    location = BoardLocation.new(location)
    board[location.x][location.y]
  end

  def turn_attempt(turn_array)
    move_start = BoardLocation.new(turn_array[0])
    move_end = BoardLocation.new(turn_array[1])
    return false if check_loc(move_start).nil?
    return piece_take(move_start, move_end) unless check_loc(move_end).nil?

    piece_move(move_start, move_end)
  end

  def piece_move(move_start, move_end)
    piece = check_loc(move_start)
    return false unless piece.valid_move?(move_start, move_end)

    remove_piece(move_start)
    place_piece(move_end, piece)
    true
  end

  def piece_take(move_start, move_end)
    piece = check_loc(move_start)
    return false unless piece.valid_take?(move_start, move_end)

    remove_piece(move_start)
    place_piece(move_end, piece)
    true
  end

  def remove_piece(location)
    board[location.x][location.y] = nil
  end

  def place_piece(location, piece)
    piece.moved
    board[location.x][location.y] = piece
  end

  def starting_board
    accum = Array.new(4) { Array.new(8) { nil } }
    pawn_row_b = Array.new(8) { Pawn.new }
    pawn_row_w = Array.new(8) { Pawn.new(:white) }
    row_two_b = generate_bot_row
    row_two_w = generate_bot_row(:white)
    accum.prepend(pawn_row_w).prepend(row_two_w).append(pawn_row_b).append(row_two_b)
  end

  def generate_bot_row(color = :black)
    start = [Rook.new(color), Knight.new(color), Bishop.new(color)]
    mid = [Queen.new(color), King.new(color)]
    start + mid + start.reverse
  end

  def piece_array_to_s(array)
    array.map { |val| val.nil? ? ' ' : val.to_s }.join(' ')
  end

  def to_s
    temp = board.reverse.each_with_index.map { |val, i| "#{8 - i} |" + piece_array_to_s(val) }.join("\n")
    temp + "\n   _______________\n   a b c d e f g h"
  end
end

game = ChessGame.new
game.game_loop
# puts BoardLocation.new('e2').inspect
# game = ChessGame.new
# puts game
# game.turn_attempt('e2', 'e4')
# game.turn_attempt('e7', 'e5')
# game.turn_attempt('f1', 'c4')
# game.turn_attempt('f8', 'c5')
# game.turn_attempt('b2', 'b4')
# game.turn_attempt('c5', 'b4')
# puts game
