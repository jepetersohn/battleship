require_relative '../lib/grid.rb'
require_relative '../lib/ship.rb'

# Game class. Main program class.
class Game
  attr_reader :state

  STATES = %i(initialized ready error terminated game_over).freeze
  GRID_SIZE = 10.freeze
  HIT_CHAR = 'X'.freeze
  MISS_CHAR = '-'.freeze
  NO_SHOT_CHAR = '·'.freeze

  SHIPS_DEFS = [
    { size: 4, type: 'Battleship' },
    { size: 4, type: 'Battleship' },
    { size: 5, type: 'Aircraft carrier' }
  ].freeze

  STATES.each { |state| define_method("#{state}?") { @state == state } }

  def initialize
    @state = :initialized
    @command_line = nil
    @shots = Array.new
    @fleet = Array.new
    play
  end

  def play
    begin
      @hits_counter = 0
      @matrix = Array.new(GRID_SIZE) { Array.new(GRID_SIZE, ' ') }
      @matrix_opponent = Array.new(GRID_SIZE) { Array.new(GRID_SIZE, NO_SHOT_CHAR) }
      @grid_opponent = Grid.new @matrix_opponent

      @state = :ready
      add_fleet
      begin
        console
        case @command_line
        when 'D'
          @grid_opponent.status_line = String.new
          show(debug: true)
        when 'Q' then @state = :terminated
        when 'I'
          @state = :initialized
          @grid_opponent.status_line = 'Initialized'
          show
        when /^[A-J]([1-9]|10)$/
          shoot
          @grid_opponent.status_line = "[#{@state}] Your input: #{@command_line} (#{@shots.size})"
          show
        else
          @grid_opponent.status_line = 'Error: Incorrect input'
          show
          clear_error
        end
      end until game_over? && terminated? && initialized? && ENV['RACK_ENV'] == 'test'
    end while initialized?
    report
    self
  end

  def show(options = {})
    @grid_opponent.new(@matrix_opponent).show

    if options[:debug]
      @grid = Grid.new(@matrix, @fleet)
      @grid.status_line = 'DEBUG MODE'
      @grid.show
    end
  end

  # just some user input validations
  def <<(str)
    return unless str
    @command_line = str.upcase
  end

  private

  def add_fleet
    @fleet = Array.new
    SHIPS_DEFS.each do |ship_definition|
      ship = Ship.new(@matrix, ship_definition).build
      @fleet.push ship
      @hits_counter += ship_definition.fetch(:size) # need for game over check
      ship.location.each { |coordinates| @matrix[coordinates.first][coordinates[1]] = true}
    end
  end

  def console
    return nil if ENV['RACK_ENV'] == 'test'
    input = [(print 'Enter coordinates (row, col), e.g. A5 (I - initialize, Q to quit): '), gets.rstrip][1]
    self << input
  end

  def shoot
    if xy == convert
      @shots.push(xy)
      @fleet.each do |ship|
        if ship.location.include? xy
          @matrix_oponent[xy[0]][xy[1]] = HIT_CHAR

          @hits_counter -= 1
          Grid.row("You sank my #{ship.type}!") if (ship.location - @shots).empty?
          @state = :game_over if game_over?

          return
        end
      end
      @matrix_opponent[xy[0]][xy[1]] = MISS_CHAR
    end
  end

  def game_over?
    @hits_counter.zero?
  end

  def convert
    x, y = @command_line.first, @command_line[1..-1]
    [x.ord - 65, y.to_i - 1]
  end

  def clear_error
    @state = :ready
  end

  def report
    msg = if terminated?
            "Terminated by user after #{@shots.size} shots!"
          elsif game_over?
            "Well done! You completed the game in #{@shots.size} shots"
          end
    Grid.row(msg)
    msg
  end
end
