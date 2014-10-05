require_relative 'spec_helper'
require 'double_dispatcher_deep'
require_relative 'double_dispatcher_spec'

RSpec.describe DoubleDispatcher::Deep do
  before do
    stub_const 'MyModule', Module.new
    stub_const 'MyClass', Class.new{ include MyModule }
    stub_const 'MySubClass', Class.new(MyClass)
  end

  let(:dispatcher_class){ DoubleDispatcher::Deep }

  # it_behaves_like 'double dispatcher'

  context 'deep' do
    let(:dispatcher){ dispatcher_class.new }

    it 'iterates through arrays' do
      dispatcher[MyClass] = ->(t){ t.the_message }
      target = MyClass.new
      allow(target).to receive(:the_message).and_return(:the_response)

      result = dispatcher.dispatch([target, target])
      expect(result).to eq([:the_response, :the_response])
    end

    it 'iterates through hashes' do
      dispatcher[MyClass] = ->(t){ t.the_message }
      target = MyClass.new
      allow(target).to receive(:the_message).and_return(:the_response)

      result = dispatcher.dispatch({:A => target})
      expect(result).to eq({:A => :the_response})
    end
  end
end
