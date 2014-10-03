require_relative 'spec_helper'
require 'double_dispatcher'

RSpec.describe DoubleDispatcher do
  before :all do
    MyClass = Class.new
  end

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

  it 'calls the block matching the class of the object' do
    dispatcher = DoubleDispatcher.new
    dispatcher[MyClass] = ->(o){ o.the_message }
    object = MyClass.new
    expect(object).to receive(:the_message).and_return(:the_response)

    result = dispatcher.dispatch object
    expect(result).to eq(:the_response)
  end
end
