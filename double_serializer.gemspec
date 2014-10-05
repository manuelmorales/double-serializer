# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'double_serializer/version'

Gem::Specification.new do |spec|
  spec.name          = "double_serializer"
  spec.version       = DoubleSerializer::VERSION
  spec.authors       = ["Manuel Morales"]
  spec.email         = ["manuelmorales@gmail.com"]
  spec.summary       = %q{Allows the creation of double dispatch based serializers.}
  spec.description   = %q{Allows the creation of custom serializers the do not pollute the serialized classes thanks to double dispatch.}
  spec.homepage      = "https://github.com/manuelmorales/double_serializer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rspec", "~> 3.1.0"
end
