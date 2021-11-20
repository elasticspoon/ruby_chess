# frozen_string_literal: true

require_relative 'piece_movement'
require_relative 'board_location'
require_relative 'chess_pieces'
require_relative 'chess_board'
require 'yaml'

class ChessGame
  include TwoDCopy
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
    save = player_input.downcase.match(/^s$/)
    return save_game if save

    matcher = player_input.downcase.match(/^([a-h][1-8])\s*([a-h][1-8])$/)
    return false if matcher.nil?

    [BoardLocation.new(matcher[1]), BoardLocation.new(matcher[2])]
  end

  def player_loop
    loop do
      puts 'Input a move in a1 b2 format. s to save.'
      input = parse_input(gets.chomp)
      next unless input && chess_board.valid_turn?(input[0], input[1], !@white_turn)

      chess_board.prev_move = input
      break
    end
    chess_board.pawn_promo
  end

  def turn_loop
    puts chess_board
    puts "#{@white_turn ? 'White' : 'Black'} turn:"
  end

  def game_start
    loop do
      puts 'Would you like to (l)oad a game or start a (n)ew game?'
      input = gets.chomp
      next if input.downcase.match(/^[ln]$/).nil?

      load_game if input.downcase == 'l'
      break
    end
    game_loop
  end

  def game_loop
    puts 'Play Chess:'
    loop do
      turn_loop
      player_loop
      result = game_end?(white_turn)
      return result if result
    end
  end

  def game_end?(player_color)
    case mate?(player_color, chess_board.board)
    when nil
      false
    when true
      'Checkmate.'
    when false
      'Stalemate.'
    end
  end

  # nil is no mate. true is checkmate. false is stalemate
  def mate?(player_color, game_board)
    return nil unless no_unchecked_moves(player_color, game_board)

    chess_board.check?(player_color, game_board)
  end

  def no_unchecked_moves(player_color, game_board)
    pieces = game_board.flatten.compact.filter { |piece| piece.black? == player_color }
    pieces.each do |piece|
      piece.update_legal_moves(game_board)
      possbile_moves = piece.valid_moves + piece.valid_takes
      possbile_moves.each do |possbile_move|
        return false unless chess_board.turn_attempt_bad(piece.loc, possbile_move, player_color,
                                                         game_board) == true
      end
    end
    true
  end

  def save_game
    File.open('game.save', 'w') do |file|
      file.puts YAML.dump({ turn: @white_turn, board: chess_board })
    end
    puts 'Game Saved.'
    false
  end

  def load_game
    File.open('game.save', 'r') do |file|
      val = YAML.load(file)
      @white_turn = val[:turn]
      @chess_board = val[:board]
    end
    puts 'Game Loaded.'
  end
end

# game = ChessGame.new
# puts game.game_start
