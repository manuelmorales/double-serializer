require_relative 'spec_helper'
require 'double_dispatchable'

RSpec.describe DoubleDispatchable do
  let(:klass) { Class.new{ include DoubleDispatchable } }
  let(:instance) { klass.new }
  subject { instance }

  before do
    animal = Class.new do
      def speak
        'animal sound'
      end
    end
    stub_const('Animal', animal)

    dog = Class.new Animal do
      def speak
        'woof'
      end
    end
    stub_const('Dog', dog)

    cat = Class.new Animal do
      def speak
        'meow'
      end
    end
    stub_const('Cat', cat)
  end

  it 'allows defining different implementations for the same method' do
    klass.instance_eval do
      double_dispatch(:feed, Dog){|o| "A dog says #{o.speak}"}
      double_dispatch(:feed, Cat){|o| "A cat says #{o.speak}" }
    end

    expect(subject.feed(Dog.new)).to eq 'A dog says woof'
    expect(subject.feed(Cat.new)).to eq 'A cat says meow'
  end

  it 'allows access to instance variables and methods' do
    klass.class_eval do
      attr_accessor :suffix

      double_dispatch(:feed, Dog){|dog| dog.speak + suffix }
    end

    subject.suffix = '!'
    dog = Dog.new

    expect(subject.feed(Dog.new)).to eq 'woof!'
  end

  it 'resolves processors up in the target object ancestry' do
    klass.instance_eval do
      double_dispatch(:feed, Animal){|o| "An animal says #{o.speak}"}
      double_dispatch(:feed, Cat){|o| "A cat says #{o.speak}" }
    end

    expect(subject.feed(Animal.new)).to eq 'An animal says animal sound'
    expect(subject.feed(Cat.new)).to eq 'A cat says meow'
  end

  it 'resolves processors up in its own ancestry' do
    klass.instance_eval do
      double_dispatch(:feed, Dog){|o| "A dog says #{o.speak}"}
      double_dispatch(:feed, Cat){|o| "A cat says #{o.speak}" }
    end

    subklass = Class.new klass do
      double_dispatch(:feed, Cat){|o| "A different #{o.speak}" }
    end

    sub_subject = subklass.new
    expect(sub_subject.feed(Dog.new)).to eq 'A dog says woof'
    expect(sub_subject.feed(Cat.new)).to eq 'A different meow'
  end

  it 'doesn\'t override original processors when modifying the subclass' do
    klass.instance_eval do
      double_dispatch(:feed, Cat){|o| "A cat says #{o.speak}" }
    end

    subklass = Class.new klass do
      double_dispatch(:feed, Cat){|o| "A different #{o.speak}" }
    end

    expect(subject.feed(Cat.new)).to eq 'A cat says meow'
  end
end
