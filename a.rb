require'bundler'
Bundler.require
require'json'

RSpec.configure do |c|
  c.color = true
end

class Serializer
  def serialize object
    case object
    when Doc then {name: "#{object.name}.#{object.format}"}.to_json
    else
      object.to_json
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
end

RSpec::Core::Runner.invoke
