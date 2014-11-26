require 'double_dispatcher'

module DoubleDispatchable
  module ClassMethods
    private

    def double_dispatch name, klass = nil, &block
      unless double_dispatchers[name]
        define_method name do |object|
          instance_exec(object, &(double_dispatchers[name][object]))
        end

        double_dispatchers[name] = DoubleDispatcher.new
      end

      double_dispatchers[name][klass] = block if klass
    end

    def double_dispatchers
      @double_dispatchers ||= {}
    end

    # Forwarding un-matched objects to the parent dispatchable class
    def inherited klass
      new_dispatchers = {}
      @double_dispatchers.each do |name, dispatcher|
        new_dispatchers[name] = DoubleDispatcher.new{|o| instance_exec(o, &dispatcher[o]) }
      end

      klass.instance_variable_set(:@double_dispatchers, new_dispatchers)
    end
  end

  def self.included klass
    klass.extend ClassMethods
  end

  def double_dispatchers
    self.class.send(:double_dispatchers)
  end
end

