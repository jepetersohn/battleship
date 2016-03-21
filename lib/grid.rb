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

  def show(inputs)
    (system('clear') || system('cls')) unless ENV['RACK_ENV'] == 'test'
    welcome
    status
    board
    history(inputs)
  end

  def debug
    Grid.row 'DEBUG MODE'
    setup_with_fleet if @fleet
    board
  end

  # separate presentation layer
  def self.row(txt = nil)
    txt ? puts(txt) : puts('')
  end

  private

  def welcome
    Grid.row
    Grid.row '>> Welcome to Battleship'
    Grid.row
  end

  def status
    Grid.row status_line
    Grid.row
  end

  def board
    Grid.row '    ' + AXE_DIGITS.join(' ')
    @matrix.each_with_index do |grow, index|
      Grid.row(" #{AXE_LETTERS[index]}  #{grow.join(' ')}  #{AXE_LETTERS[index]}")
    end
    Grid.row '    ' + AXE_DIGITS.join(' ')
  end

  def history(inputs)
    Grid.row
    Grid.row inputs[0..-1].join(' ')
    Grid.row
  end

  def setup_with_fleet
    if @fleet
      @fleet.each do |ship|
        ship.location.each { |coordinates| @matrix[coordinates.first][coordinates[1]] = HIT_CHAR }
      end
    end
    @matrix
  end
end
