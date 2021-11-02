class ChessPiece
  BOARD_SIZE = 8
  attr_reader :piece_moves, :piece_type, :piece_color, :has_moved

  def initialize(piece_color = :black)
    @piece_color = piece_color
    @has_moved = false
    @piece_moves = arrays_to_locations(set_piece_moves)
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
    one_tile_locs = arrays_to_locations(one_tile_moves)
    max_dist_tile_moves = (0...max_move_dist).inject([]) do |accum, move_dist|
      max_dist_move = one_tile_locs.map { |one_tile_move| one_tile_move * move_dist }
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
    piece_type
  end

  def ==(other)
    piece_type == other.piece_type
  end
end

class Rook < ChessPiece
  include VerticalMovement
  def initialize(piece_color = :black)
    super(piece_color)
    @piece_type = black? ? "\u2656" : "\u265C"
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
    @piece_type = black? ? "\u2659" : "\u265F"
    @en_passant = false
  end

  def set_piece_moves
    return [[1, 0]] if !black? && has_moved
    return [[2, 0], [1, 0]] if !black? && !has_moved
    return [[-1, 0]] if black? && has_moved
    return [[-2, 0], [-1, 0]] if black? && !has_moved
  end

  def set_piece_takes
    return [[-1, 1], [-1, -1]] if black?
    return [[1, 1], [1, -1]] unless black?
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
    @piece_type = black? ? "\u2658" : "\u265E"
  end

  def set_piece_moves
    knight_moves
  end
end

class Bishop < ChessPiece
  include DiagonalMovement
  def initialize(piece_color = :black)
    super(piece_color)
    @piece_type = black? ? "\u2657" : "\u265D"
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
    @piece_type = black? ? "\u2655" : "\u265B"
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
    @piece_type = black? ? "\u2654" : "\u265A"
  end

  def set_piece_moves
    single_dist_moves = vert_moves + diag_moves
    set_max_move_distance(single_dist_moves, 1)
  end
end
