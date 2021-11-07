class ChessPiece
  include TwoDCopy
  BOARD_SIZE = 8
  attr_reader :piece_moves, :piece_type, :piece_color, :has_moved, :valid_takes, :valid_moves, :game_state
  attr_accessor :loc

  def initialize(piece_color = :black)
    @piece_color = piece_color
    @has_moved = false
    @piece_moves = set_piece_moves
    @loc = nil
  end

  def arrays_to_locations(array)
    array.map { |move| BoardLocation.new(move) }
  end

  def board_legal?(location)
    (0...BOARD_SIZE).include?(location.x) && (0...BOARD_SIZE).include?(location.y)
  end

  def set_piece_moves
    nil
  end

  def set_max_move_distance(one_tile_moves, max_move_dist)
    raise "can't move a distance less than 1" if max_move_dist < 1

    one_tile_locs = arrays_to_locations(one_tile_moves)
    one_tile_locs.map do |location|
      (1..max_move_dist).map { |move_dist| location * move_dist }.uniq
    end
  end

  def update_legal_moves(game_board)
    (legal_moves, legal_takes) = more_piece_crap(game_board)
    state_updates(legal_takes, legal_moves, game_board)
  end

  # PLEASE THINK OF A BETTER NAME
  def more_piece_crap(game_board, legal_moves = [], legal_takes = [])
    piece_moves.each do |direction|
      direction = direction.map { |move| board_legal?(loc + move) ? loc + move : nil }.compact
      direction.each do |move|
        target = game_board[move.x][move.y]
        unless target.nil?
          legal_takes.push(move) if target.black? != black?
          break
        end
        legal_moves.push(move) if target.nil?
      end
    end
    [legal_moves.flatten, legal_takes.flatten]
  end

  def state_updates(piece_takes, piece_moves, game_board)
    @valid_takes = piece_takes
    @valid_moves = piece_moves
    @game_state = game_board
  end

  def valid_action?(end_loc, game_board)
    update_legal_moves(game_board) # if game_board != self&.game_state
    valid_take?(end_loc) || valid_move?(end_loc)
  end

  def valid_take?(end_loc)
    valid_takes.include?(end_loc)
  end

  def valid_move?(end_loc)
    valid_moves.include?(end_loc)
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
    return false unless other.is_a?(ChessPiece)

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
    @piece_moves = arrays_to_locations(set_piece_moves)
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

  def update_legal_moves(game_board)
    legal_moves = get_legal_moves(game_board)
    legal_takes = get_legal_takes(game_board)
    state_updates(legal_takes, legal_moves, game_board)
  end

  def get_legal_takes(game_board, legal_takes = [])
    piece_takes.map do |move|
      move = loc + move
      next unless board_legal?(move)

      legal_takes.push(move) unless game_board[move.x][move.y].nil?
    end
    legal_takes
  end

  def get_legal_moves(game_board, legal_moves = [])
    piece_moves.map do |move|
      move = loc + move
      next unless board_legal?(move)

      legal_moves.push(move) if game_board[move.x][move.y].nil?
    end
    legal_moves
  end
end

class Knight < ChessPiece
  include KnightMovement
  def initialize(piece_color = :black)
    super(piece_color)
    @piece_type = black? ? "\u2658" : "\u265E"
  end

  def set_piece_moves
    arrays_to_locations(knight_moves)
  end

  def more_piece_crap(game_board, legal_moves = [], legal_takes = [])
    piece_moves.each do |move|
      move = loc + move
      next unless board_legal?(move)

      legal_moves.push(move) if game_board[move.x][move.y].nil?
      legal_takes.push(move) unless game_board[move.x][move.y].nil?
    end
    [legal_moves, legal_takes]
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
