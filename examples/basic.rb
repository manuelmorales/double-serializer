require_relative '../lib/double_serializer'
require 'json'

# The serializable animals
Animal = Struct.new(:name)
Lion = Class.new(Animal)
Meerkat = Class.new(Animal)

# The serializer class
class Serializer
  include DoubleSerializer::Serializable

  simplifies Animal do |animal|
    {name: animal.name}
  end

  simplifies Lion do |lion|
    {name: "King #{lion.name}"}
  end

  serializes do |obj|
    JSON.dump obj
  end
end

# Let's serialize
serializer = Serializer.new
zoo = [Lion.new('Simba'), Meerkat.new('Timon')]

result = serializer.serialize(zoo)

puts "=> #{result}"

