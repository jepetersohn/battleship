# Grid class
class Grid
  attr_accessor :status_line

  AXE_LETTERS = %w( A B C D E F G H I J ).freeze
  AXE_DIGGITS = %w( 1 2 3 4 5 6 7 8 9 10 ).freeze
  HIT_CHAR = 'X'.freeze
  MISS_CHAR = '-'.freeze

  def initialize
    @matrix = []
    @fleet = []
  end

  def build(matrix, fleet = nil)
    @matrix = matrix
    @fleet = fleet
    self
  end

  def show
    print_header
    setup_with_fleet if @fleet
    @matrix.each_with_index do |grow, index|
      Grid.row("#{AXE_LETTERS[index]} #{grow.join(' ')}")
    end
  end

  # separate presentation layer

  def self.row(txt)
    puts txt if txt
  end

  private

  def setup_with_fleet
    if @fleet
      @fleet.each do |ship|
        ship.location.each do |coordinates|
          @matrix[coordinates[0]][coordinates[1]] = HIT_CHAR
        end
      end
    end
    @matrix
  end

  def print_header
    Grid.row('=' * AXE_DIGGITS.size * 3)
    Grid.row(status_line)
    Grid.row("  #{AXE_DIGGITS.join(' ')}")
  end
end
