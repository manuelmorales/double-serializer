require_relative 'spec_helper'

RSpec.shared_examples_for 'double dispatcher' do
  let(:target){ double('target') }
  let(:dispatcher){ dispatcher_class.new }

  it 'raises NotImplementedError by default' do
    expect{ subject.dispatch(Object.new) }.to raise_error(NotImplementedError)
  end

  it 'calls the initialization block by default' do
    dispatcher = dispatcher_class.new{|t| t.the_default_message }
    expect(target).to receive(:the_default_message)

    dispatcher.dispatch target
  end

  it 'returns the result of calling the default block' do
    dispatcher = dispatcher_class.new{|t| t.the_default_message }
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

  it 'calls the block matching an ancestor module of the target' do
    dispatcher[MyModule] = ->(t){ t.the_message }
    target = MyClass.new

    expect(target).to receive(:the_message)
    dispatcher.dispatch target
  end

  it 'allows defining processors when initializing' do
    dispatcher = dispatcher_class.new(MyClass => ->(t){ t.the_message })
    target = MyClass.new

    expect(target).to receive(:the_message)
    dispatcher.dispatch target
  end

  it 'allows defining processors whith a block using for()' do
    dispatcher.for(MyClass){|t| t.the_message }
    target = MyClass.new

    expect(target).to receive(:the_message)
    dispatcher.dispatch target
  end

  it 'allows resolving using []' do
    block = ->(t){ t.the_message }
    dispatcher[MyClass] = block
    expect(dispatcher[MyClass]).to eq(block)
  end
end
