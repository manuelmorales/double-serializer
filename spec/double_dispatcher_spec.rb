require_relative 'spec_helper'
require 'double_dispatcher'

RSpec.describe DoubleDispatcher do
  it 'returns object as is by default' do
    dispatcher = DoubleDispatcher.new
    original = Object.new

    result = dispatcher.dispatch original
    expect(result).to eq(original)
  end
end
