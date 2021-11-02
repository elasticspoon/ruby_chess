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

    col = matched_string[1].ord - 65
    row = matched_string[2].to_i - 1

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
