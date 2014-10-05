require 'double_dispatcher'

class CustomSerializer
  attr_accessor :finish_proc

  def serialize object
    run_final_proc simplify(object)
  end

  def []= key, value
    dispatcher[key]= value
  end

  def initialize &finish_proc
    finish_proc ||= method(:do_nothing)
    @finish_proc = finish_proc
  end

  def simplify object
    dispatcher.dispatch object
  end

  private

  def run_final_proc object
    finish_proc.call object
  end

  def dispatcher
    @dispatcher ||= build_dispatcher
  end

  def build_dispatcher
    DoubleDispatcher::Deep.new
  end

  def do_nothing object
    object
  end
end
