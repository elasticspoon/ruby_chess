# frozen_string_literal: true

require_relative 'piece_movement'
require_relative 'board_location'
require_relative 'chess_pieces'
require_relative 'chess_board'

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
      break if chess_board.valid_turn?(input, !@white_turn)
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
