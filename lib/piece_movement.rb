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
