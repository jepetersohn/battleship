# Grid class
require 'spec_helper'
require 'grid'
require 'ship'

describe Grid do
  let(:grid) { Grid.new.build([]) }

  before(:each) { allow(Grid).to receive(:row) }

  it 'is valid' do
    expect(grid).to be_kind_of(Grid)
  end

  it 'has letters array' do
    expect(Grid::AXE_LETTERS).to eql(%w(A B C D E F G H I J))
  end

  it 'has digits array' do
    expect(Grid::AXE_DIGITS).to eql(%w(1 2 3 4 5 6 7 8 9 10))
  end

  it '#show' do
    expect(grid).to respond_to(:show)
  end

  it 'has row class method' do
    expect(described_class).to respond_to(:row)
  end

  it '#setup_with_fleet' do
    matrix = Array.new(4) { Array.new(4, ' ') }

    ship1 = Ship.new(matrix, size: 1).build
    ship1.instance_variable_set('@location', [[0, 2]])

    fleet = ship1, Ship.new(matrix, size: 2).build

    grid = Grid.new matrix
    grid.instance_variable_set('@fleet', fleet)
    expect(grid.send(:setup_with_fleet)[0][2]).to eql('X')
  end

  it '#print_header' do
    expect(Grid).to receive(:row).exactly(3).times
    grid.send(:print_header)
  end
end
