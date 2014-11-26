# DoubleSerializer

Allows the creation of custom serializers that do not pollute the serialized classes thanks to double dispatch.
It allows separating objects from their representation.


## Quick Start

Using Gemfile:

```
# Gemfile
...
gem 'double_serializer'
...

$ bundle install
```

Creating and using a custom serializer.

 * Include the module.
 * Use the `simplifies` method to define how to convert each object to a simple objects, like a hash.
 * Use the `serializes` method to define how finally convert such simplified object to a string.


```ruby
require 'double_serializer'
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

# Let's serialize something
serializer = Serializer.new
zoo = [Lion.new('Simba'), Meerkat.new('Timon')]

result = serializer.serialize(zoo)
# => [{"name":"King Simba"},{"name":"Timon"}]
```

Notice how both of them are animals, but the serializer picked the best match for Lion.


## Explanation

The serializer will actually serialize the objects in a two step process.
The first one, called *simplify* is supposed to convert the target into a simple representation.
Just with basic ruby objects like integers, strings, hashes and arrays.
The second one is the true *serialize* step. 
In which the block called at initialization will be called.
It has the purpose of taking the simplified object and converting it into a string.

This two step process was introduced because serializers are usually not idempotent and can't be nested.
However, _simplifiers_ are.


## Advanced usage

Customise your serializer at will adding new methds to it.
Everything runs within the instance of the serializer.
This allows serializer customizations and nesting:

```ruby
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

serializer = Serializer.new
serializer.name_prefix = 'An animal called'
simba = Lion.new('Simba', Lion.new('Mufasa'))

result = serializer.serialize(simba)
# => {"name":"An animal called Simba","father":{"name":"An animal called Mufasa"}}
```

Another important point is inheritance.
You can create subclasses of your Serializer which will try to match their own simplifiers first
and delegate to the parent class when none found.


## Contributing

Do not forget to run the tests with:

```bash
bundle exec rake
```

And bump the version with any of:

```bash
$ gem bump --version 1.1.1       # Bump the gem version to the given version number
$ gem bump --version major       # Bump the gem version to the next major level (e.g. 0.0.1 to 1.0.0)
$ gem bump --version minor       # Bump the gem version to the next minor level (e.g. 0.0.1 to 0.1.0)
$ gem bump --version patch       # Bump the gem version to the next patch level (e.g. 0.0.1 to 0.0.2)
```

