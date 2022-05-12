class Square
  @visited = Hash.new
  @width = 8
  @height = @width
  @column_numbers = {a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8}
  @column_names = [nil, :a, :b, :c, :d, :e, :f, :g, :h]

  def self.new(*args, &block)
    args = decode(*args) if args.length == 1
    return nil unless possible(*args)
    name = encode(*args)
    cached = @visited[name]
    return cached if cached
    allocate.tap { |r| @visited[name] = r; r.send(:initialize, *args, &block)}
  end

  def self.reset
    @visited = Hash.new
  end

  def self.width
    @width
  end

  def self.height
    @height
  end

  attr_accessor :row
  attr_accessor :column
  attr_accessor :last


  def self.decode(str)
    column = @column_numbers[str[0].to_sym]
    row = Integer(str[1])
    [row, column]
  end

  def self.encode(row, column)
    (@column_names[column].to_s + row.to_s).to_sym
  end

  def self.possible(row, column)
    row <= height && column <= width && row > 0 && column > 0
  end

  def initialize(row, column)
    @visitor = nil
    @row = row 
    @column = column
    @visited = false
  end

  def relative(row_delta, column_delta)
    Square.new(row + row_delta, column + column_delta)
  end

  def -(other)
    (self.column - other.column) + (self.row - other.row)
  end

  def ==(other)
    other.row == self.row && other.column == self.column
  end

  def delta_row(other)
    self.row - other.row
  end

  def delta_column(other)
    self.column - other.column
  end

  def visit(other)
    @visitor ||= other
    @visited = true
  end

  def visited?
    @visited
  end

  def chain(path = [])
    path.unshift(self)
    return @visitor.chain(path) if visited? && @visitor
    path.flatten.map(&:encode)
  end

  def to_s
    Square.encode(row, column)
  end
  alias_method :encode, :to_s

  def color
    @row % 2 == @column % 2 ? :black : :white
  end
end

class Knight
  attr_accessor :square
  def initialize(square)
    square.visit(nil)
    @square = square
    @moves = [-1, -2], [-1, 2], [1, 2], [1, -2], [-2, -1], [-2, 1], [2, -1], [2, 1]
  end

  def next_move_set(visited: false)
    @moves.map { |move| square.relative(*move) }.reject(&:nil?).select { |s| s.visited? == visited }.map { |s| s.visit(square); s }
  end

  def move(square)
    square.visit(@square) # guarded by ||=
    @square = square
  end

  def search(destination)
    return [square].map(&:encode) if square == destination
    available = next_move_set
    until destination == square
      available.each do |a|
        if a == destination
          result = a.chain
          Square.reset
          return result
        end
      end
      available.map! { |a| move(a); next_move_set }.flatten!
    end
  end
end

start = Square.new(:a1)
finish = Square.new(:c3)
piece = Knight.new(start)
pp piece.search(finish)
