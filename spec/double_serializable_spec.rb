require_relative 'spec_helper'

RSpec.describe Serializable do
  before do
    stub_const 'Doc', Struct.new(:name, :format)
  end

  let(:klass) do
    Class.new do
      include Serializable
      simplifies(Doc) { |doc| {name: "#{doc.name}.#{doc.format}"} }
      serializes { |obj| obj.to_json }
    end
  end

  let(:instance) do
    klass.new{|simplified_object| simplified_object.to_json }
  end

  subject { instance }

  it 'serializes hashes' do
    original = {'a' => 1}
    result = subject.serialize(original)

    expect(result).to eq('{"a":1}')
  end

  it 'serializes hashes of arrays' do
    original = {a: [1,2]}
    result = subject.serialize(original)

    expect(result).to eq('{"a":[1,2]}')
  end

  it 'serializes files with name and format' do
    original = Doc.new 'report', 'txt'
    result = subject.serialize original
    expect(result).to eq('{"name":"report.txt"}')
  end

  it 'serializes hashes of files correctly' do
    original = {my_file: Doc.new('report', 'txt')}
    result = subject.serialize original
    expect(result).to eq('{"my_file":{"name":"report.txt"}}')
  end

  it 'serializes arrays of files correctly' do
    original = [Doc.new('report', 'txt'), Doc.new('audio', 'mp3')]
    result = subject.serialize original
    expect(result).to eq('[{"name":"report.txt"},{"name":"audio.mp3"}]')
  end

  it 'allows matching objects by themselves' do
    original = double('original', custom_method: 'custom_result')

    klass.class_eval do
      simplifies(original) { |o| o.custom_method }
    end

    result = subject.serialize original
    expect(result).to eq('"custom_result"')
  end

  it 'allows nesting' do
    complex_name = double('name', stringify: 'complex_report')

    klass.class_eval do
      simplifies(complex_name) { |o| o.stringify }
      simplifies(Doc) { |doc| { name: self.simplify(doc.name) } }
    end

    original = Doc.new(complex_name, 'txt')
    result = subject.serialize original
    expect(result).to eq('{"name":"complex_report"}')
  end

  it 'returns the result of simplifying if no final proc is given' do
    klass = Class.new{ include Serializable }
    subject = klass.new

    original = {'a' => 1}
    result = subject.serialize(original)
    expect(result).to eq(original)
  end

  it 'raises an exception when the object is of a non supported class' do
    expect{ subject.serialize(Object.new) }.to raise_error(NotImplementedError)
  end

  it 'leaves some basic objects untouched' do
    [1, -1, 1.2, 'a', :a, true, false].each do |obj|
      expect(subject.simplify(obj)).to eq obj
    end
  end
end

