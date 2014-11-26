require_relative '../lib/double_serializer'
require 'json'

# The serializable animals
Animal = Struct.new(:name, :father)
Lion = Class.new(Animal)
Meerkat = Class.new(Animal)

# The serializer class
class Serializer
  include DoubleSerializer::Serializable
  attr_accessor :name_prefix

  simplifies Animal do |animal|
    result = {}
    result[:name] = "#{name_prefix} #{animal.name}"            # Using an instance method of the serializer
    result[:father] = simplify(animal.father) if animal.father # Nesting
    result
  end

  serializes do |obj|
    JSON.dump obj
  end
end

# Let's serialize
serializer = Serializer.new
serializer.name_prefix = 'An animal called'
simba = Lion.new('Simba', Lion.new('Mufasa'))

result = serializer.serialize(simba)

puts "=> #{result}"

