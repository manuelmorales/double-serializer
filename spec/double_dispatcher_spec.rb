require_relative 'spec_helper'
require 'double_dispatcher'

RSpec.describe DoubleDispatcher do
  before do
    stub_const 'MyModule', Module.new
    stub_const 'MyClass', Class.new{ include MyModule }
    stub_const 'MySubClass', Class.new(MyClass)
  end

  let(:dispatcher_class){ DoubleDispatcher }

  it_behaves_like 'double dispatcher'
end
