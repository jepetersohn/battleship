require "spec_helper"
require "game"

describe Game do
  let(:game) { Game.new }

  it "has array of ships" do
    expect(Game::SHIPS_DEFS).to be_kind_of(Array)
    expect(Game::SHIPS_DEFS).to_not be_empty    
  end

  it "has array of states" do
    expect(Game::STATES).to be_kind_of(Array)
  end

  it "has GRID_SIZE" do
    expect(Game::GRID_SIZE).to be_kind_of(Integer)
  end

  describe "#initialize" do
    before(:each) do 
      allow_any_instance_of(described_class).to receive(:play)
    end

    it "is valid" do
      expect(game).to be_kind_of(Game)
    end

    it "sets 'initialize' state" do
      expect(game).to be_initialized
    end

    it "inits shots counter" do
      expect(game.shots).to be_kind_of(Array)
    end

    it "inits fleet" do
      expect(game.instance_variable_get(:@fleet)).to be_kind_of(Array)
      expect(game.instance_variable_get(:@fleet)).to be_empty      
    end

    it "calls #play" do
      expect_any_instance_of(described_class).to receive(:play)
      Game.new
    end
  end

  describe '#play' do
    before(:each)  do
      # escape from endless loop
      allow(game).to receive(:initialized?).and_return(false)
    end

    it "is valid" do
      expect(game).to respond_to(:play)
    end

    it "sets 'ready' state" do
      expect(game).to be_ready
    end

    it "initialize @matrix array" do
      expect(game.instance_variable_get(:@matrix)).to be_kind_of(Array)
    end

    it "initialize @matrix_oponent array" do
      expect(game.instance_variable_get(:@matrix_oponent)).to be_kind_of(Array)
    end    

    describe "makes fleet" do
      it "calls #add_fleet" do
        expect(game).to receive(:add_fleet)
        game.play
      end

      it "with correct size" do
        expect(game.instance_variable_get(:@fleet).size).to eql(Game::SHIPS_DEFS.size)
      end

      it "with correct type" do
        expect(game.instance_variable_get(:@fleet)[0]).to be_kind_of(Ship)
      end      
    end

    it "calls #console" do
      expect(game).to receive(:console)
      game.play
    end

    describe "with input from console" do
      it "when 'Q'" do
        game.instance_variable_set("@command_line","Q")
        expect{ game.play }.to change{ game.state }.from('ready').to('terminated')
      end

      it "when 'D'" do
        game.instance_variable_set("@command_line","D")
        expect(game).to receive(:show).with( debug: true )
        game.play
      end

      describe "when 'I'" do
        before(:each) do
          game.instance_variable_set("@command_line", "I")
          # escape from endless loop
          allow(game).to receive(:initialized?).and_return(false)
        end

        it "setup grids's status_line" do
          expect{ game.play }.to change{ game.instance_variable_get("@grid_oponent").instance_variable_get("@status_line") }.to("Initialized")
        end

        it "calls #show" do
          expect(game).to receive(:show)
          game.play
        end

        it "changes state" do
          expect{ game.play }.to change{ game.state }.from('ready').to('initialized')
        end
      end

      describe "when 'A5'" do
        before(:each) { game.instance_variable_set("@command_line","A5") }

        it "calls #shoot" do
          expect(game).to receive(:shoot)
          game.play
        end

        it "changes status line" do
          expect{ game.play }.to change{ game.instance_variable_get("@grid_oponent").instance_variable_get("@status_line") }.from("Error: Incorrect input").to("[ready] Your input: A5")
        end

        it "calls #show" do
          expect(game).to receive(:show)
          game.play
        end
      end
    end
  end

  describe '#show' do
    it "is valid" do
      expect(game).to respond_to(:show)
    end

    it "calls Grid show" do
      expect_any_instance_of(Grid).to receive(:show).twice
      game.show
    end

    describe "in debug mode" do
      it "changes status_line" do
        expect{ game.show(debug: true) }.to change{ game.instance_variable_get("@grid").instance_variable_get("@status_line") }.from(nil).to("DEBUG MODE")
      end
    end
  end

  describe '#game_over?' do
    it "it returns true when hits_counter is zero" do
      game.instance_variable_set("@hits_counter", 0)
      expect(game.send(:game_over?)).to be_truthy
    end

    it "it returns false when hits_counter is not zero" do
      expect(game.send(:game_over?)).to be_falsy      
    end
  end

  describe "with stubbed #play" do
    before(:each) { allow_any_instance_of(described_class).to receive(:play) }

    describe "#clear_error" do
      it "cleans error status" do
        game.instance_variable_set("@state","error")
        expect{game.send(:clear_error)}.to change{
          game.instance_variable_get(:@state)
        }.from('error').to('ready')
      end
    end

    describe '#convert' do
      it "converts from A5 to coordinates" do
        game.command_line = "B5"
        expect(game.send(:convert)).to eql([1, 4])
      end
    end

    describe "#report" do
      it "when terminated returns text" do
        game.instance_variable_set("@state","terminated")
        expect(game.send(:report)).to eql "Terminated by user after 0 shots!"
      end

      it "when gameover returns text" do
        game.instance_variable_set("@state","gameover")
        expect(game.send(:report)).to eql "Well done! You completed the game in 0 shots"
      end
    end

    describe "<<" do
      it "returns nil when input is nil" do
        expect(game << nil).to be nil
      end

      it "returns upcase" do
        expect(game << "ble").to eql "BLE"
      end

      it "sets game command line" do
        expect{ game << "BLE" }.to change { 
          game.instance_variable_get(:@command_line) 
        }.from(nil).to("BLE")
      end  
    end
  end
end
