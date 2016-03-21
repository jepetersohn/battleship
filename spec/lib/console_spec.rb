# Game launch
require 'spec_helper'
require 'game'

describe 'Console file' do
  it 'loads Game' do
    expect(Game).to receive(:new)
    require 'console'
  end
end
