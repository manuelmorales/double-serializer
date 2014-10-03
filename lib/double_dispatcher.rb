class DoubleDispatcher
  def dispatch object
    processors[object].call object rescue binding.pry
  end

  def []= key, value
    processors[key]= value
  end

  private

  def processors
    @processors ||= build_processors_hash
  end

  def build_processors_hash
    hash = { Object => method(:do_nothing) }
    hash.default_proc = method(:match_ancestry)
    hash
  end

  def match_ancestry hash, object
    object.class.ancestors.each do |ancestor|
      return processors[ancestor] if processors.has_key?(ancestor)
    end
  end

  def do_nothing value
    value
  end
end
