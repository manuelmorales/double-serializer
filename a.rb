require'bundler'
Bundler.require
require'json'

RSpec.configure do |c|
  c.color = true
end

class CustomSerializer
  attr_accessor :finish_proc

  def serialize object
    finish simplify(object)
  end

  def []= key, value
    simplifiers[key]= value
  end

  def initialize &finish_proc
    @finish_proc = finish_proc
  end

  def simplify object
    simplifiers[object].call object
  end

  private

  def finish object
    finish_proc.call object
  end

  def simplifiers
    @simplifiers ||= new_simplyfiers
  end

  def new_simplyfiers
    simplifiers = {
      Object => method(:do_nothing),
      Hash => method(:simplify_hash),
      Enumerable => method(:simplify_array),
    }
    simplifiers.default_proc = method(:match_ancestry)
    simplifiers
  end

  def match_ancestry hash, object
    object.class.ancestors.each do |ancestor|
      return simplifiers[ancestor] if simplifiers.has_key?(ancestor)
    end
  end

  def do_nothing object
    object
  end

  def simplify_array object
    object.inject([]) do |array, value|
      array << simplify(value)
    end
  end

  def simplify_hash object
    object.inject({}) do |hash, key_value|
      key, value = key_value
      hash[key] = simplify(value)
      hash
    end
  end
end

Doc = Struct.new :name, :format

RSpec.describe CustomSerializer do
  subject do
    serializer = CustomSerializer.new{|simplified_object| simplified_object.to_json }
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
end

RSpec::Core::Runner.invoke
