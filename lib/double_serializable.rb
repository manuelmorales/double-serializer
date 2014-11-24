module DoubleSerializable
  module ClassMethods
    def simplifies klass, &block
      dispatcher[klass] = block
    end

    def dispatcher
      @dispatcher ||= build_dispatcher
    end

    def build_dispatcher
      DoubleDispatcher::Deep.new
    end

    def serializes &block
      @final_proc = block
    end

    def final_proc
      @final_proc
    end
  end

  def self.included klass
    klass.extend ClassMethods
  end

  def serialize object
    self.class.final_proc.call self.class.dispatcher.dispatch object
  end
end
