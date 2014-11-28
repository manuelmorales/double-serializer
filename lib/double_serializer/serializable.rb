require 'double_dispatch'

module DoubleSerializer
  module Serializable
    include DoubleDispatch::Dispatchable

    module ClassMethods
      def simplifies klass, &block
        dispatcher[klass] = block
      end

      def dispatcher
        double_dispatchers[:simplify]
      end

      def serializes &block
        @final_proc = block
      end

      def final_proc
        @final_proc ||= lambda {|o| o }
      end
    end

    def self.included klass
      klass.extend DoubleDispatch::Dispatchable::ClassMethods
      klass.extend ClassMethods
      klass.instance_variable_set(:@double_dispatchers, double_dispatchers.dup)
    end

    def serialize object
      instance_exec(simplify(object), &final_proc)
    end

    def simplify object
      instance_exec(object, &proc_for(object))
    end

    private

    def final_proc
      self.class.final_proc
    end

    def proc_for obj
      dispatcher[obj]
    end

    double_dispatch :simplify, Enumerable do |object|
      object.inject([]) do |array, value|
        array << simplify(value)
      end
    end

    double_dispatch :simplify, Hash do |object|
      object.inject({}) do |hash, key_value|
        key, value = key_value
        hash[key] = simplify(value)
        hash
      end
    end

    [Numeric, String, NilClass, TrueClass, FalseClass, Symbol].each do |klass|
      double_dispatch(:simplify, klass) { |object| object }
    end

    double_dispatch :simplify, Object do |object|
      raise(NotImplementedError.new("Don't know how to process #{object.inspect}"))
    end

    def dispatcher
      double_dispatchers[:simplify]
    end
  end
end
