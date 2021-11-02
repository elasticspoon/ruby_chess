# frozen_string_literal: true

# defines single vertical movement
module VerticalMovement
  def vert_moves
    [0, 1, 1, -1].permutation(2).filter { |x, y| x.zero? || y.zero? }.uniq
  end
end

# defines single diagonal movement
module DiagonalMovement
  def diag_moves
    [1, -1].repeated_permutation(2).uniq
  end
end

module KnightMovement
  def knight_moves
    [-2, -1, 1, 2].permutation(2).filter { |x, y| x.abs != y.abs }
  end
end

class ChessPiece
  BOARD_SIZE = 8
  attr_reader :piece_moves, :piece_type, :piece_color, :has_moved

  def initialize(piece_color = :black)
    @piece_moves = arrays_to_locations(set_piece_moves)
    @piece_color = piece_color
    @has_moved = false
  end

  def arrays_to_locations(array)
    array.map { |move| BoardLocation.new(move) }
  end

  def board_legal?(location)
    location = BoardLocation.new(location)
    (0...BOARD_SIZE).include?(location.x) && (0...BOARD_SIZE).include?(location.y)
  end

  def set_piece_moves
    nil
  end

  def set_max_move_distance(one_tile_moves, max_move_dist)
    max_dist_tile_moves = (0...max_move_dist).inject([]) do |accum, move_dist|
      max_dist_move = one_tile_moves.map { |one_tile_move| one_tile_move * move_dist }
      accum + max_dist_move
    end
    max_dist_tile_moves.uniq
  end

  def get_current_moves(*start_loc)
    start_loc = BoardLocation.new(start_loc)
    all_moves = piece_moves.map { |move| start_loc + move }
    all_moves.filter { |move| board_legal?(move) }
  end

  def valid_take?(start_loc, end_loc)
    valid_move?(start_loc, end_loc)
  end

  def valid_move?(start_loc, end_loc)
    start_loc = BoardLocation.new(start_loc)
    end_loc = BoardLocation.new(end_loc)
    potential_moves = get_current_moves(start_loc)
    return nil unless potential_moves

    potential_moves.include?(end_loc)
  end

  def moved
    @has_moved = true
  end

  def black?
    piece_color == :black
  end

  def to_s
    piece_color == :black ? piece_type.upcase : piece_type.downcase
  end
end

class Rook < ChessPiece
  include VerticalMovement
  def initialize(piece_color = :black)
    super(piece_color)
    @piece_type = black? ? "\u265C" : "\u2656"
  end

  def set_piece_moves
    single_dist_moves = vert_moves
    set_max_move_distance(single_dist_moves, BOARD_SIZE)
  end
end

class Pawn < ChessPiece
  attr_reader :piece_takes

  def initialize(piece_color = :black)
    super(piece_color)
    @piece_takes = arrays_to_locations(set_piece_takes)
    @piece_type = black? ? "\u265F" : "\u2659"
    @en_passant = false
  end

  def set_piece_moves
    return [[0, 1]] if !black? && has_moved
    return [[0, 2], [0, 1]] if !black? && !has_moved
    return [[0, -1]] if black? && has_moved
    return [[0, -2], [0, -1]] if black? && !has_moved
  end

  def set_piece_takes
    return [[1, -1], [-1, -1]] if black?
    return [[1, 1], [-1, 1]] unless black?
  end

  def valid_take?(start_loc, end_loc)
    start_loc = BoardLocation.new(start_loc)
    end_loc = BoardLocation.new(end_loc)
    potential_moves = get_current_takes(start_loc)
    return nil unless potential_moves

    potential_moves.include?(end_loc)
  end

  def get_current_takes(*start_loc)
    start_loc = BoardLocation.new(start_loc)
    all_moves = piece_takes.map { |move| move + start_loc }
    all_moves.filter { |move| board_legal?(move) }
  end
end

class Knight < ChessPiece
  include KnightMovement
  def initialize(piece_color = :black)
    super(piece_color)
    @piece_type = black? ? "\u265E" : "\u2658"
  end

  def set_piece_moves
    knight_moves
  end
end

class Bishop < ChessPiece
  include DiagonalMovement
  def initialize(piece_color = :black)
    super(piece_color)
    @piece_type = black? ? "\u265D" : "\u2657"
  end

  def set_piece_moves
    single_dist_moves = diag_moves
    set_max_move_distance(single_dist_moves, BOARD_SIZE)
  end
end

class Queen < ChessPiece
  include DiagonalMovement
  include VerticalMovement
  def initialize(piece_color = :black)
    super(piece_color)
    @piece_type = black? ? "\u265B" : "\u2655"
  end

  def set_piece_moves
    single_dist_moves = vert_moves + diag_moves
    set_max_move_distance(single_dist_moves, BOARD_SIZE)
  end
end

class King < ChessPiece
  include DiagonalMovement
  include VerticalMovement
  def initialize(piece_color = :black)
    super(piece_color)
    @piece_type = black? ? "\u265A" : "\u2654"
  end

  def set_piece_moves
    single_dist_moves = vert_moves + diag_moves
    set_max_move_distance(single_dist_moves, 1)
  end
end

class BoardLocation
  attr_reader :x, :y

  def initialize(*args)
    location = parse_location_input(args)
    raise Error, 'location err' unless location

    @x = location[0]
    @y = location[1]
  end

  def parse_string(string)
    matched_string = string.chomp.upcase.match(/^([A-H])([1-8])$/)
    return false unless matched_string

    row = matched_string[1].ord - 65
    col = matched_string[2].to_i - 1

    [row, col]
  end

  def parse_location_input(input_arr)
    input_arr = input_arr.flatten
    return [input_arr[0].x, input_arr[0].y] if input_arr[0].is_a?(BoardLocation)
    return parse_string(input_arr[0]) if input_arr[0].is_a?(String)
    return [input_arr[0], input_arr[1]] if input_arr.all?(Integer)

    false
  end

  def ==(other)
    x == other.x && y == other.y
  end

  def +(other)
    BoardLocation.new(x + other.x, y + other.y)
  end

  def *(other)
    BoardLocation.new(x * other, y * other)
  end
end

rook = Pawn.new
rook.valid_move?([4, 4], [-1, -1])
rook.valid_move?([1, 0], [0, 0])
