# Grid class
require 'spec_helper'
require 'grid'
require 'ship'

describe Grid do
  let(:grid) { Grid.new([], []) }

  before(:each) { allow(Grid).to receive(:puts) }

  it { respond_to described_class::HIT_CHAR }
  it { respond_to described_class::MISS_CHAR }
  it { respond_to described_class::NO_SHOT_CHAR }

  it 'has letters array' do
    expect(described_class::AXE_LETTERS).to eql(%w(A B C D E F G H I J))
  end

  it 'has digits array' do
    expect(described_class::AXE_DIGITS).to eql(%w(1 2 3 4 5 6 7 8 9 10))
  end

  it { respond_to described_class::SIZE }

  it 'has GRID_SIZE' do
    expect(described_class::SIZE).to be_kind_of(Integer)
  end

  it 'has input history length' do
    expect(described_class::HISTORY_LENGTH).to be_a Integer
  end

  it 'is valid' do
    expect(grid).to be_kind_of(Grid)
  end

  it '#show' do
    expect(grid).to respond_to(:show)
  end

  describe '#row' do
    it 'is class method' do
      expect(described_class).to respond_to(:row)
    end

    it 'returns nil' do
      expect(described_class.row('foo')).to eql nil
    end

    it 'calls puts' do
      expect(described_class).to receive('puts')
      described_class.row
    end
  end

  it '#setup_with_fleet' do
    matrix = Array.new(4) { Array.new(4, ' ') }

    ship1 = Ship.new(matrix, size: 1)
    ship1.instance_variable_set('@location', [[0, 2]])

    fleet = ship1, Ship.new(matrix, size: 2)

    grid = Grid.new(matrix, [])
    grid.instance_variable_set('@fleet', fleet)
    expect(grid.send(:setup_with_fleet)[0][2]).to eql('X')
  end

  describe '#input_tail' do
    it 'is Array' do
      expect(grid.send(:input_tail)).to be_a Array
    end

    it 'is same as input array' do
      inputs = %w(1 2 3)
      grid.instance_variable_set('@inputs', inputs)
      expect(grid.send(:input_tail)).to be inputs
    end

    it 'has tail' do
      stub_const('Grid::HISTORY_LENGTH', 3)
      inputs = %w(1 2 3 4)
      grid.instance_variable_set('@inputs', inputs)
      expect(grid.send(:input_tail)).to eq ['..', '2', '3', '4']
    end
  end
end
