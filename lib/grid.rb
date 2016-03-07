# Grid class
class Grid
  attr_accessor :status_line

  SIZE = 10
  AXE_LETTERS = %w( A B C D E F G H I J ).freeze
  AXE_DIGITS = %w( 1 2 3 4 5 6 7 8 9 10 ).freeze
  HIT_CHAR = 'X'.freeze
  MISS_CHAR = '-'.freeze
  NO_SHOT_CHAR = '·'.freeze

  def initialize(matrix, fleet = nil)
    @matrix = matrix
    @fleet = fleet
  end

  def show
    print_header
    setup_with_fleet if @fleet
    @matrix.each_with_index { |grow, index| Grid.row("#{AXE_LETTERS[index]} #{grow.join(' ')}") }
  end

  # separate presentation layer

  def self.row(txt)
    puts txt if txt
  end

  private

  def setup_with_fleet
    if @fleet
      @fleet.each do |ship|
        ship.location.each { |coordinates| @matrix[coordinates.first][coordinates[1]] = HIT_CHAR }
      end
    end
    @matrix
  end

  def print_header
    Grid.row(?= * AXE_DIGITS.size * 3)
    Grid.row status_line
    Grid.row("  #{AXE_DIGITS.join(' ')}")
  end
end
