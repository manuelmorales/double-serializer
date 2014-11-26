require_relative 'spec_helper'
require 'double_serializer'

RSpec.describe DoubleSerializer do
  it 'holds the rest of constants'do
    expect(DoubleSerializer::VERSION).to be_a String
    expect(DoubleSerializer::Serializable).to be_a Module
  end
end

