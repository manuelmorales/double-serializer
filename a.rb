require'bundler'
Bundler.require
require'json'

RSpec.configure do |c|
  c.color = true
end

class Serializer
  def serialize object
    simplify(object).to_json
  end

  private

  def simplify object
    case object
    when Doc then {name: "#{object.name}.#{object.format}"}
    when Array then 
      object.inject([]) do |array, value|
        array << simplify(value)
      end
    when Hash then 
      object.inject({}) do |hash, key_value|
        key, value = key_value
        hash[key] = simplify(value)
        hash
      end
    else
      object
    end
  end
end

Doc = Struct.new :name, :format

RSpec.describe Serializer do
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

  it 'serializes files with name and extension' do
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
end

RSpec::Core::Runner.invoke
