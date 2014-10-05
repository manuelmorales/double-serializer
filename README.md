# DoubleSerializer

Allows the creation of custom serializers that do not pollute the serialized classes thanks to double dispatch.
This will allow you to separate objects from their representation.


## Quick Start

Install the gem Gemfile:

```
# Gemfile
gem 'double_serializer'

$ bundle install
```

Creating and using a custom serializer:

```ruby
my_serializer = DoubleSerializer.new{|target| JSON.dump target }
my_serializer[Animal] = ->(animal){ name: animal.name }
my_serializer[Lion] = ->(lion){ name: "King #{animal.name}" }

zoo = [Lion.new(name: 'Simba'), Meerkat.new(name: 'Timon')]

my_serializer.serialize(zoo)

# [
#   { "name":"King Simba" },
#   { "name":"Timon" }
# ]

```


## Contributing

Do not forget to run the tests with:

```bash
rake
```

And bump the version with any of:

```bash
$ gem bump --version 1.1.1       # Bump the gem version to the given version number
$ gem bump --version major       # Bump the gem version to the next major level (e.g. 0.0.1 to 1.0.0)
$ gem bump --version minor       # Bump the gem version to the next minor level (e.g. 0.0.1 to 0.1.0)
$ gem bump --version patch       # Bump the gem version to the next patch level (e.g. 0.0.1 to 0.0.2)
```

