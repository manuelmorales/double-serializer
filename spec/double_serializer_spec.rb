require_relative 'spec_helper'
require 'double_serializer'


RSpec.describe DoubleSerializer do
  before do
    stub_const 'Doc', Struct.new(:name, :format)
  end

  subject do
    serializer = DoubleSerializer.new{|simplified_object| simplified_object.to_json }
    serializer[Doc]= lambda{|doc| {name: "#{doc.name}.#{doc.format}"} }
    serializer
  end

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
    subject[original]= lambda{|o| o.custom_method }
    result = subject.serialize original
    expect(result).to eq('"custom_result"')
  end

  it 'allows nesting' do
    complex_name = double('name', stringify: 'complex_report')

    subject[complex_name]= lambda{|o| o.stringify }
    subject[Doc] = lambda do |doc|
      {
        name: subject.simplify(doc.name)
      }
    end

    original = Doc.new(complex_name, 'txt')
    result = subject.serialize original
    expect(result).to eq('{"name":"complex_report"}')
  end

  it 'leaves as a hashes and arrays by default' do
    serializer = DoubleSerializer.new
    serializer[Doc]= lambda{|doc| {name: "#{doc.name}.#{doc.format}"} }
    original = Doc.new('report', 'txt')

    result = serializer.serialize original
    expect(result).to eq({name:"report.txt"})
  end

  context 'readme examples' do
    it 'shows a basic example' do
      stub_const('Animal', Struct.new(:name))
      stub_const('Lion', Class.new(Animal))
      stub_const('Meerkat', Class.new(Animal))

      my_serializer = DoubleSerializer.new{|target| JSON.dump target }
      my_serializer[Animal] = ->(animal){ {name: animal.name} }
      my_serializer[Lion] = ->(lion){ {name: "King #{lion.name}"} }

      zoo = [Lion.new('Simba'), Meerkat.new('Timon')]
      result = my_serializer.serialize(zoo)
      expect(result).to eq('[{"name":"King Simba"},{"name":"Timon"}]')
    end

    it 'shows bad nested serialization' do
      stub_const('Animal', Struct.new(:name, :children))
      stub_const('Lion', Class.new(Animal))

      my_serializer = DoubleSerializer.new{|target| JSON.dump target }
      my_serializer[Animal] = lambda do |animal|
        {
          name: animal.name,
          children: animal.children.map{|c| my_serializer.serialize(c) }
        }
      end
      result = my_serializer.serialize Lion.new('Mufasa', [Lion.new('Simba', [])])
      expect(result).to eq('{"name":"Mufasa","children":["{\"name\":\"Simba\",\"children\":[]}"]}')
    end

    it 'shows good nested serialization' do
      stub_const('Animal', Struct.new(:name, :children))
      stub_const('Lion', Class.new(Animal))

      my_serializer = DoubleSerializer.new{|target| JSON.dump target }

      my_serializer[Animal] = lambda do |animal|
        {
          name: animal.name,
          children: animal.children.map{|c| my_serializer.simplify(c) } # <- .simplify()
        }
      end
      result = my_serializer.serialize Lion.new('Mufasa', [Lion.new('Simba', [])])
      expect(result).to eq('{"name":"Mufasa","children":[{"name":"Simba","children":[]}]}')
    end
  end
end

