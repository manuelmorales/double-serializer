require_relative 'spec_helper'
require 'double_dispatcher'

RSpec.describe DoubleDispatcher do
  it 'returns object as is by default' do
    dispatcher = DoubleDispatcher.new
    original = Object.new

    result = dispatcher.dispatch original
    expect(result).to eq(original)
  end

  it 'calls the initialization block by default' do
    dispatcher = DoubleDispatcher.new{|o| o.the_default_message }
    original = Object.new
    expect(original).to receive(:the_default_message)

    dispatcher.dispatch original
  end
end
