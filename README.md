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

Creating and using a custom serializer:

```ruby
Animal = Struct.new(:name))
Lion = Class.new(Animal))
Meerkat = Class.new(Animal))

my_serializer = DoubleSerializer.new{|target| JSON.dump target }
my_serializer[Animal] = ->(animal){ {name: animal.name} }
my_serializer[Lion] = ->(lion){ {name: "King #{lion.name}"} }

zoo = [Lion.new('Simba'), Meerkat.new('Timon')]
result = my_serializer.serialize(zoo)
# => [{"name":"King Simba"},{"name":"Timon"}]
```

Notice how both of them are animals, but the serializer picked the best match for Lion.


## Advanced usage

The serializer will actually serialize the objects in a two step process.
The first one, called *simplify* is supposed to convert the target into a simple representation.
Just with basic ruby objects like integers, strings, hashes and arrays.
The second one is the true *serialize* step. 
In which the block called at initialization will be called.
It has the purpose of taking the simplified object and converting it into a string.

This two step process was introduced because serializers are usually not idempotent and can't be  nested.
However, _simplifiers_ are:

```ruby
# BAD

Animal = Struct.new(:name, :children)
Lion = Class.new(Animal)

my_serializer = DoubleSerializer.new{|target| JSON.dump target }
my_serializer[Animal] = lambda do |animal|
  {
    name: animal.name,
    children: animal.children.map{|c| my_serializer.serialize(c) }
  }
end
result = my_serializer.serialize Lion.new('Mufasa', [Lion.new('Simba', [])])
# => {"name":"Mufasa","children":["{\"name\":\"Simba\",\"children\":[]}"]}

```

Notice how Simba's quotes are scaped. It has been serialized twice :unamused:.
The right way of doing it is to nest simplifications, not serialization:

```ruby
# GOOD

my_serializer[Animal] = lambda do |animal|
  {
    name: animal.name,
    children: animal.children.map{|c| my_serializer.simplify(c) } # <- .simplify()
  }
end

result = my_serializer.serialize Lion.new('Mufasa', [Lion.new('Simba', [])])
# => {"name":"Mufasa","children":[{"name":"Simba","children":[]}]}

```

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

