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
    instance_exec(simplify(object), &final_proc)
  end

  def simplify object
    instance_exec(object, &proc_for(object))
  end

  private

  def final_proc
    self.class.final_proc
  end

  def dispatcher
    self.class.dispatcher
  end

  def proc_for obj
    dispatcher[obj]
  end
end
