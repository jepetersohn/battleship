require 'spec_helper'
require 'game'

describe Game do
  let(:game) { Game.new }

  before(:each) { allow(Grid).to receive(:row) }

  it 'has array of ships' do
    expect(Game::SHIPS_DEFS).to be_kind_of(Array)
    expect(Game::SHIPS_DEFS).to_not be_empty
  end

  it 'has array of states' do
    expect(Game::STATES).to be_kind_of(Array)
  end

  it 'has GRID_SIZE' do
    expect(Game::GRID_SIZE).to be_kind_of(Integer)
  end

  describe '#initialize' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:play)
    end

    it 'is valid' do
      expect(game).to be_kind_of(Game)
    end

    it 'sets initialize state' do
      expect(game).to be_initialized
    end

    it 'initializes shots counter' do
      expect(game.instance_variable_get('@shots')).to be_kind_of(Array)
    end

    it 'initializes fleet' do
      expect(game.instance_variable_get(:@fleet)).to be_kind_of(Array)
      expect(game.instance_variable_get(:@fleet)).to be_empty
    end

    it 'calls #play' do
      expect_any_instance_of(described_class).to receive(:play)
      Game.new
    end
  end

  describe 'status helpers' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:play)
    end

    it 'is valid' do
      described_class::STATES.each do |state|
        expect(game).to respond_to("#{state}?")
      end
    end
  end

  describe '#play' do
    before(:each)  do
      # escape from endless loop
      allow(game).to receive(:initialized?).and_return(false)
    end

    it 'sets ready state' do
      expect(game).to be_ready
    end

    it 'initializes your matrix' do
      expect(game.instance_variable_get(:@matrix)).to be_a Array
    end

    it "initializes opponent's matrix" do
      expect(game.instance_variable_get(:@matrix_opponent)).to be_a Array
    end

    it "initializes opponent's grid" do
      expect(game.instance_variable_get(:@grid_opponent)).to be_a Grid
    end

    describe 'with fleet' do
      it 'calls #create_fleet!' do
        expect(game).to receive(:create_fleet!)
        game.play
      end

      it 'correct size' do
        expect(game.instance_variable_get(:@fleet).size)
          .to eql(described_class::SHIPS_DEFS.size)
      end

      it 'correct type' do
        expect(game.instance_variable_get(:@fleet).first).to be_kind_of(Ship)
      end

      it 'sets game hits counter' do
        expect(game.instance_variable_get(:@hits_counter))
          .to eql described_class::SHIPS_DEFS.inject(0) { |a, e| a + e[:size] }
      end
    end

    it 'calls control_loop' do
      expect_any_instance_of(described_class).to receive(:control_loop)
      Game.new
    end
  end

  describe '#control_loop' do
    it 'calls #console' do
      expect(game).to receive(:console)
      game.play
    end

    describe 'with input from console' do
      it "when 'Q'" do
        game.instance_variable_set('@command_line', 'Q')
        expect { game.play }.to change {
          game.state
        }.from(:ready).to(:terminated)
      end

      it "when 'D'" do
        game.instance_variable_set('@command_line', 'D')
        expect(game).to receive(:show).with(debug: true)
        game.play
      end

      describe "when 'I'" do
        before(:each) do
          game.instance_variable_set('@command_line', 'I')
          # escape from endless loop
          allow(game).to receive(:initialized?).and_return(false)
        end

        it 'changes state' do
          expect { game.play }.to change {
            game.state
          }.from(:ready).to(:initialized)
        end

        it "setups grids's status_line" do
          expect { game.play }.to change {
            game.instance_variable_get('@grid_opponent')
              .instance_variable_get('@status_line')
          }.to('Initialized')
        end

        it 'calls #show' do
          expect(game).to receive(:show)
          game.play
        end
      end

      describe "when 'A5'" do
        before(:each) { game.instance_variable_set('@command_line', 'A5') }

        it 'calls #shoot' do
          expect(game).to receive(:shoot).once
          game.play
        end

        it 'it is valid' do
          expect(Grid).to receive(:row).with('[ready] Your input: A5 (1)')
          game.play
        end

        it 'calls #show' do
          expect(game).to receive(:show)
          game.play
        end
      end
    end
  end

  describe '#show' do
    it 'is valid' do
      expect(game).to respond_to(:show)
    end

    it 'calls Grid show' do
      expect_any_instance_of(Grid).to receive(:show).twice
      game.show
    end

    describe 'in debug mode' do
      it 'changes status_line' do
        expect { game.show(debug: true) }.to change {
          game.instance_variable_get('@grid')
            .instance_variable_get('@status_line')
        }.from(nil).to('DEBUG MODE')
      end
    end
  end

  describe '#fleet_detroyed?' do
    it 'returns true when hits_counter is zero' do
      game.instance_variable_set('@hits_counter', 0)
      expect(game.send(:fleet_detroyed?)).to be_truthy
    end

    it 'returns false when hits_counter is not zero' do
      expect(game.send(:fleet_detroyed?)).to be_falsy
    end
  end

  describe 'with stubbed #play' do
    before(:each) { allow_any_instance_of(described_class).to receive(:play) }

    describe '#clear_error' do
      it 'cleans error status' do
        game.instance_variable_set('@state', :error)
        expect { game.send(:clear_error) }.to change {
          game.instance_variable_get(:@state)
        }.from(:error).to(:ready)
      end
    end

    describe '#convert' do
      it 'converts from A5 to coordinates' do
        game.instance_variable_set('@command_line', 'B5')
        expect(game.send(:convert)).to eql([1, 4])
      end
    end

    describe '#report' do
      it 'when terminated returns text' do
        game.instance_variable_set('@state', :terminated)
        expect(game.send(:report)).to eql 'Terminated by user after 0 shots!'
      end

      it 'when game_over returns text' do
        game.instance_variable_set('@state', :game_over)
        expect(game.send(:report))
          .to eql 'Well done! You completed the game in 0 shots'
      end
    end

    describe '<<' do
      it 'returns nil when input is nil' do
        expect(game << nil).to be nil
      end

      it 'returns upcase' do
        expect(game << 'ble').to eql 'BLE'
      end

      it 'sets game command line' do
        expect { game << 'BLE' }.to change {
          game.instance_variable_get(:@command_line)
        }.from(nil).to('BLE')
      end
    end
  end

  describe '#shoot' do
    it 'returns nil when user input is nil' do
      expect(game.send(:shoot)).to be nil
    end

    it 'sets shots array' do
      game.instance_variable_set('@command_line', 'A1')
      expect { game.play }.to change {
        game.instance_variable_get('@shots')
      }.from([]).to([[0, 0]])
    end

    describe 'when hit' do
      before(:each) do
        @target = game.instance_variable_get('@fleet').first.location.first
        allow_any_instance_of(described_class).to receive(:convert).and_return(@target)
      end

      it 'sets HIT_CHAR' do
        expect { game.send(:shoot) }.to change {
          game.instance_variable_get('@matrix_opponent')[@target[0]][@target[1]]
        }.to(described_class::HIT_CHAR)
      end

      it 'calls #hit' do
        expect_any_instance_of(described_class).to receive(:hit)
        game.send(:shoot)
      end
    end

    it 'when miss sets MISS_CHAR' do
      target = game.instance_variable_get('@fleet').first.location.pop
      allow_any_instance_of(described_class).to receive(:convert).and_return(target)
      expect { game.send(:shoot) }.to change {
        game.instance_variable_get('@matrix_opponent')[target[0]][target[1]]
      }.to(described_class::MISS_CHAR)
    end
  end

  describe '#hit' do
    let(:ship) { game.instance_variable_get('@fleet').first }

    it 'decrease hits counter' do
      expect { game.send(:hit, ship) }.to change {
        game.instance_variable_get('@hits_counter')
      }.by(-1)
    end

    it 'can finish the game' do
      allow_any_instance_of(Game).to receive(:fleet_detroyed?).and_return(true)
      expect { game.send(:hit, ship) }.to change {
        game.state
      }.from(:ready).to(:game_over)
    end
  end
end
