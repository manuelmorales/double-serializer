require_relative 'spec_helper'
require 'double_dispatcher'

RSpec.describe DoubleDispatcher do
  before :all  do
    MyClass = Class.new
    MySubClass = Class.new(MyClass)
  end

  let(:dispatcher){ DoubleDispatcher.new }
  let(:target){ double('target') }

  it 'returns target as is by default' do
    result = dispatcher.dispatch target
    expect(result).to eq(target)
  end

  it 'calls the initialization block by default' do
    dispatcher = DoubleDispatcher.new{|t| t.the_default_message }
    expect(target).to receive(:the_default_message)

    dispatcher.dispatch target
  end

  it 'returns the result of calling the default block' do
    dispatcher = DoubleDispatcher.new{|t| t.the_default_message }
    allow(target).to receive(:the_default_message).and_return(:the_response)

    result = dispatcher.dispatch target
    expect(result).to eq(:the_response)
  end

  it 'calls the block matching the class of the target' do
    dispatcher[MyClass] = ->(t){ t.the_message }
    target = MyClass.new

    expect(target).to receive(:the_message)
    dispatcher.dispatch target
  end

  it 'returns the result of calling the block' do
    dispatcher[MyClass] = ->(t){ t.the_message }
    target = MyClass.new
    allow(target).to receive(:the_message).and_return(:the_response)

    result = dispatcher.dispatch target
    expect(result).to eq(:the_response)
  end

  it 'calls the block matching an ancestor class of the target' do
    dispatcher[MyClass] = ->(t){ t.the_message }
    target = MySubClass.new

    expect(target).to receive(:the_message)
    dispatcher.dispatch target
  end
end
